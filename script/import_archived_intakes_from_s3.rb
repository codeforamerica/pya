#!/usr/bin/env ruby
require_relative "../config/environment"

class ImportArchivedIntakesFromS3 < Thor
  default_task :load

  desc "load", "Downloads gzipped dump from S3 and loads it into the database"
  def load(path)
    pg_load(db_connection_string, path)
  end

  no_tasks do
    def pg_load(connection_string, file_path)
      sql_string = read_input(file_path)

      Open3.popen3("psql", "-d", connection_string) do |i, o, e, _|
        i.puts(sql_string)
        i.close

        case o.read
        in ""
          next
        in String => output
          say output, :green
        end

        case e.read
        in ""
          next
        in String => error
          say error, :red
        end
      end
    end

    def read_input(file_name)
      if Rails.env.development? && ENV["AWS_ACCESS_KEY_ID"].blank?
        read_from_file(file_name)
      else
        read_from_s3(file_name)
      end
    end

    def read_from_file(file_name)
      File.open(file_name, 'r', binmode: true) do |file_obj|
        Zlib.gunzip(file_obj.read)
      end
    end

    def read_from_s3(file_name)
      Zlib.gunzip(
        s3_client.get_object(
          bucket: 'archived-intakes',
          key: file_name
        ).body.read
      )
    end

    def db_connection_string
      config_hash = ActiveRecord::Base.connection_db_config.as_json.with_indifferent_access[:configuration_hash]

      case config_hash
      in host:, port:, username:, password:, database:
        "postgres://#{username}:#{password}@#{host}:#{port}/#{database}"
      in host:, port:, database:
        "postgres://#{host}:#{port}/#{database}"
      end
    end

    def source_bucket
    end

    def s3_client
      Aws::S3::Client.new(
        region: 'us-east-1',
        credentials: s3_credentials,
        force_path_style: true,
        endpoint: ENV.fetch('LOCALSTACK_ENDPOINT', nil)
      )
    end

    def s3_credentials
      if ENV["AWS_ACCESS_KEY_ID"].present? # is this for local?
        Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV.fetch("AWS_SECRET_ACCESS_KEY", nil))
      else
        Aws::Credentials.new(
          Rails.application.credentials.dig(:aws, :access_key_id),
          Rails.application.credentials.dig(:aws, :secret_access_key)
        )
      end
    end
  end
end

ImportArchivedIntakesFromS3.start
