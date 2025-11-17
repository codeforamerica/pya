require_relative "../config/environment"

class AttachSubmissionPdfs < Thor
  default_task :attach

  desc "attach MAPPING_JSON_KEY BUCKET_NAME", "Attach PDFs from S3 to StateFileArchivedIntakes"
  def attach(mapping_json_key, bucket_name)
    mappings = load_mappings_from_s3(mapping_json_key, bucket_name)

    attached_count = 0
    already_attached_count = 0
    missing_count = 0

    mappings.each do |id_str, s3_key|
      intake_id = id_str.to_i
      intake = StateFileArchivedIntake.find_by(id: intake_id)

      next unless intake

      if intake.submission_pdf.attached?
        puts "Intake #{intake_id} already has a submission_pdf, skipping"
        already_attached_count += 1
        next
      end

      begin
        puts "Attaching PDF #{s3_key} to intake #{intake_id}..."

        io = pdf_io_from_s3(s3_key, bucket_name)

        intake.submission_pdf.attach(
          io: io,
          filename: "#{s3_key}.pdf",
          content_type: "application/pdf"
        )

        intake.save! if intake.changed?
        attached_count += 1
      rescue Aws::S3::Errors::NoSuchKey
        puts "Missing S3 key #{s3_key} for intake #{intake_id}, skipping"
        missing_count += 1
      rescue => e
        puts "Error attaching for intake #{intake_id}: #{e.class} - #{e.message}"
      end
    end

    puts "---------------------------------------"
    puts "Finished attaching PDFs"
    puts "Total successfully attached: #{attached_count}"
    puts "Already had attachments: #{already_attached_count}"
    puts "Missing S3 keys: #{missing_count}"
    puts "---------------------------------------"
  end

  no_tasks do
    def load_mappings_from_s3(json_key, bucket_name)
      body = s3_client.get_object(
        bucket: bucket_name,
        key: json_key
      ).body.read

      JSON.parse(body)
    end

    def pdf_io_from_s3(file_name, bucket_name)
      body = s3_client.get_object(
        bucket: bucket_name,
        key: file_name
      ).body.read

      StringIO.new(body)
    end

    def s3_client
      if ENV["AWS_ACCESS_KEY_ID"].present? &&
          ENV["AWS_SECRET_ACCESS_KEY"].present?
        Aws::S3::Client.new(
          region: "us-east-1",
          credentials: Aws::Credentials.new(
            ENV["AWS_ACCESS_KEY_ID"],
            ENV["AWS_SECRET_ACCESS_KEY"],
            ENV["AWS_SESSION_TOKEN"] # can be nil; SDK handles that
          )
        )
      else
        Aws::S3::Client.new(region: "us-east-1")
      end
    end
  end
end

AttachSubmissionPdfs.start
