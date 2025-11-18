#!/usr/bin/env ruby
require_relative "../config/environment"
require "json"
require "stringio"
require "thread"

class AttachSubmissionPdfs < Thor
  default_task :attach

  # Usage (single task):
  #   bundle exec ruby script/attach_submission_pdfs.rb attach MAPPING_JSON_KEY BUCKET
  #
  # With sharding (e.g., 4 tasks):
  #   ATTACH_SHARD_INDEX=0 ATTACH_SHARD_COUNT=4 ATTACH_THREADS=4 \
  #     bundle exec ruby script/attach_submission_pdfs.rb attach demo-intakes.json pya-staging-submission-pdfs-import
  #
  #   ATTACH_SHARD_INDEX=1 ATTACH_SHARD_COUNT=4 ATTACH_THREADS=4 \
  #     bundle exec ruby script/attach_submission_pdfs.rb attach demo-intakes.json pya-staging-submission-pdfs-import
  #
  #   ... and so on for shard_index 2, 3
  desc "attach MAPPING_JSON_KEY BUCKET", "Attach PDFs from S3 and write results to the same bucket"
  def attach(mapping_json_key, bucket)
    @bucket = bucket
    @mapping_json_key = mapping_json_key

    set_logger_levels!

    mappings = load_mappings_from_s3(@mapping_json_key)
    mappings_by_id = mappings.transform_keys { |id_str| id_str.to_i }

    # Optional sharding: ATTACH_SHARD_INDEX / ATTACH_SHARD_COUNT
    shard_index = ENV["ATTACH_SHARD_INDEX"]&.to_i
    shard_count = ENV["ATTACH_SHARD_COUNT"]&.to_i

    if shard_index && shard_count && shard_count > 1
      mappings_by_id.select! { |id, _| (id % shard_count) == shard_index }
      puts "Sharding enabled: shard #{shard_index + 1}/#{shard_count}, processing #{mappings_by_id.size} mappings"
    end

    total = mappings_by_id.size
    puts "Loaded #{total} mappings from #{@bucket}/#{@mapping_json_key}"

    timestamp = Time.current.strftime("%Y%m%d-%H%M%S")
    base_name = File.basename(@mapping_json_key, File.extname(@mapping_json_key))

    shard_suffix =
      if shard_index && shard_count && shard_count > 1
        "-shard-#{shard_index + 1}-of-#{shard_count}"
      else
        ""
      end

    results_key = "#{base_name}#{shard_suffix}-attachment-results-#{timestamp}.json"

    # Shared results structure (protected by mutex)
    results = {
      meta: {
        mapping_key: @mapping_json_key,
        bucket: @bucket,
        total: total,
        processed: 0,
        shard_index: shard_index,
        shard_count: shard_count
      },
      attached: [],         # [{ intake_id:, key: }]
      already_attached: [], # [{ intake_id: }]
      missing: [],          # [{ intake_id:, key: }]
      errors: []            # [{ intake_id:, error_class:, message: }]
    }

    mutex          = Mutex.new
    flush_interval = 500
    thread_count   = Integer(ENV.fetch("ATTACH_THREADS", "4")) # tune this per DB pool / CPU

    work_queue = Queue.new
    mappings_by_id.each_key { |intake_id| work_queue << intake_id }

    puts "Starting #{thread_count} worker threads..."

    worker_proc = proc do
      while true
        intake_id = nil

        begin
          intake_id = work_queue.pop(true) # non-blocking; raises ThreadError when empty
        rescue ThreadError
          break
        end

        s3_key = mappings_by_id[intake_id]

        unless s3_key
          mutex.synchronize do
            results[:errors] << {
              intake_id: intake_id,
              error_class: "MissingMapping",
              message: "Mapping JSON did not contain an entry for this intake"
            }
            results[:meta][:processed] += 1
          end
          next
        end

        ActiveRecord::Base.connection_pool.with_connection do
          intake = StateFileArchivedIntake.find_by(id: intake_id)
          unless intake
            mutex.synchronize do
              results[:errors] << {
                intake_id: intake_id,
                error_class: "MissingIntake",
                message: "No StateFileArchivedIntake found for this ID"
              }
              results[:meta][:processed] += 1
            end
            next
          end

          if intake.submission_pdf.attached?
            mutex.synchronize do
              results[:already_attached] << { intake_id: intake_id }
              results[:meta][:processed] += 1
            end
            next
          end

          begin
            io = pdf_io_from_s3(s3_key)

            intake.submission_pdf.attach(
              io: io,
              filename: "#{File.basename(s3_key)}.pdf",
              content_type: "application/pdf"
            )

            mutex.synchronize do
              results[:attached] << { intake_id: intake_id, key: s3_key }
              results[:meta][:processed] += 1
            end
          rescue Aws::S3::Errors::NoSuchKey
            mutex.synchronize do
              results[:missing] << { intake_id: intake_id, key: s3_key }
              results[:meta][:processed] += 1
            end
          rescue => e
            mutex.synchronize do
              results[:errors] << {
                intake_id: intake_id,
                error_class: e.class.to_s,
                message: e.message
              }
              results[:meta][:processed] += 1
            end
          end

          # Periodic flush and progress log
          mutex.synchronize do
            processed = results[:meta][:processed]
            if (processed % flush_interval).zero?
              upload_results(results_key, results)
              puts "Processed #{processed}/#{total}..."
            end
          end
        end
      end
    end

    threads = thread_count.times.map { Thread.new(&worker_proc) }
    threads.each(&:join)

    # Final upload
    upload_results(results_key, results)

    attached_count         = results[:attached].size
    already_attached_count = results[:already_attached].size
    missing_count          = results[:missing].size

    puts "---------------------------------------"
    puts "Finished attaching PDFs"
    puts "Shard index:               #{shard_index.inspect}"
    puts "Shard count:               #{shard_count.inspect}"
    puts "Total mapped (this shard): #{total}"
    puts "Successfully attached:     #{attached_count}"
    puts "Already attached:          #{already_attached_count}"
    puts "Missing S3 keys:           #{missing_count}"
    puts "Results JSON written at:   #{@bucket}/#{results_key}"
    puts "---------------------------------------"
  end

  no_tasks do
    def load_mappings_from_s3(key)
      body = s3_client.get_object(
        bucket: @bucket,
        key: key
      ).body.read

      json = JSON.parse(body)
      json.key?("mappings") ? json["mappings"] : json
    end

    def pdf_io_from_s3(key)
      body = s3_client.get_object(
        bucket: @bucket,
        key: key
      ).body.read
      StringIO.new(body)
    end

    def upload_results(key, structure)
      json = JSON.pretty_generate(structure)

      s3_client.put_object(
        bucket: @bucket,
        key: key,
        body: json
      )
    end

    def s3_client
      if ENV["AWS_ACCESS_KEY_ID"].present? &&
        ENV["AWS_SECRET_ACCESS_KEY"].present?
        Aws::S3::Client.new(
          region: "us-east-1",
          credentials: Aws::Credentials.new(
            ENV["AWS_ACCESS_KEY_ID"],
            ENV["AWS_SECRET_ACCESS_KEY"],
            ENV["AWS_SESSION_TOKEN"]
          )
        )
      else
        Aws::S3::Client.new(region: "us-east-1")
      end
    end

    def set_logger_levels!
      if defined?(Rails) && Rails.logger
        Rails.logger.level = Logger::WARN
      end

      if defined?(ActiveRecord::Base) && ActiveRecord::Base.logger
        ActiveRecord::Base.logger.level = Logger::WARN
      end

      if defined?(ActiveStorage) && ActiveStorage.respond_to?(:logger) && ActiveStorage.logger
        ActiveStorage.logger.level = Logger::WARN
      end
    end
  end
end

AttachSubmissionPdfs.start
