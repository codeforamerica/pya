#!/usr/bin/env ruby
require_relative "../config/environment"
require "json"
require "stringio"

class AttachSubmissionPdfs < Thor
  default_task :attach

  # Usage:
  #   bundle exec ruby script/attach_submission_pdfs.rb attach MAPPING_JSON_KEY BUCKET
  desc "attach MAPPING_JSON_KEY BUCKET", "Attach PDFs from S3 and write results to the same bucket"
  def attach(mapping_json_key, bucket)
    @bucket = bucket
    @mapping_json_key = mapping_json_key

    # Load mapping JSON
    mappings = load_mappings_from_s3(@mapping_json_key)
    mappings_by_id = mappings.transform_keys { |id_str| id_str.to_i }

    total = mappings_by_id.size
    puts "Loaded #{total} mappings from #{@bucket}/#{@mapping_json_key}"

    # Build results filename
    timestamp = Time.current.strftime("%Y%m%d-%H%M%S")
    base_name = File.basename(@mapping_json_key, File.extname(@mapping_json_key))
    results_key = "#{base_name}-attachment-results-#{timestamp}.json"

    # Results structure
    results = {
      meta: {
        mapping_key: @mapping_json_key,
        bucket: @bucket,
        total: total,
        processed: 0
      },
      attached: [],         # [{ intake_id:, key: }]
      already_attached: [], # [{ intake_id: }]
      missing: [],          # [{ intake_id:, key: }]
      errors: []            # [{ intake_id:, error_class:, message: }]
    }

    batch_size = 500
    flush_interval = 500

    attached_count = 0
    already_attached_count = 0
    missing_count = 0

    # Batch DB fetch with preloaded attachments
    StateFileArchivedIntake
      .where(id: mappings_by_id.keys)
      .includes(submission_pdf_attachment: :blob)
      .find_each(batch_size: batch_size) do |intake|
      intake_id = intake.id
      s3_key = mappings_by_id[intake_id]

      unless s3_key
        results[:errors] << {
          intake_id: intake_id,
          error_class: "MissingMapping",
          message: "Mapping JSON did not contain an entry for this intake"
        }
        next
      end

      if intake.submission_pdf.attached?
        already_attached_count += 1
        results[:already_attached] << {intake_id: intake_id}
        next
      end

      begin
        io = pdf_io_from_s3(s3_key)

        intake.submission_pdf.attach(
          io: io,
          filename: "#{File.basename(s3_key)}.pdf",
          content_type: "application/pdf"
        )

        attached_count += 1
        results[:attached] << {intake_id: intake_id, key: s3_key}
      rescue Aws::S3::Errors::NoSuchKey
        missing_count += 1
        results[:missing] << {intake_id: intake_id, key: s3_key}
      rescue => e
        results[:errors] << {
          intake_id: intake_id,
          error_class: e.class.to_s,
          message: e.message
        }
      ensure
        # Progress tracking
        results[:meta][:processed] += 1
        processed = results[:meta][:processed]

        if (processed % flush_interval).zero?
          upload_results(results_key, results)
          puts "Processed #{processed}/#{total}..."
        end
      end
    end

    # Final upload
    upload_results(results_key, results)

    puts "---------------------------------------"
    puts "Finished attaching PDFs"
    puts "Total mapped:               #{total}"
    puts "Successfully attached:      #{attached_count}"
    puts "Already attached:           #{already_attached_count}"
    puts "Missing S3 keys:            #{missing_count}"
    puts "Results JSON written at:    #{@bucket}/#{results_key}"
    puts "---------------------------------------"
  end

  no_tasks do
    def load_mappings_from_s3(key)
      body = s3_client.get_object(
        bucket: @bucket,
        key: key
      ).body.read

      json = JSON.parse(body)

      # If JSON was enriched before, use its "mappings"
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
  end
end

AttachSubmissionPdfs.start
