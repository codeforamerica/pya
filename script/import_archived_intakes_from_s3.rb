#!/usr/bin/env ruby
require_relative "../config/environment"

class ImportArchivedIntakesFromS3 < Thor
  default_task :load

  desc "load", "Downloads gzipped dump from S3 and loads it into the database"
  def load(path, bucket_name)
    pg_load(db_connection_string, path, bucket_name)
  end

  no_tasks do
    def pg_load(connection_string, file_path, bucket_name)
      sql_string = read_input(file_path, bucket_name)

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

    def read_input(file_name, bucket_name)
      read_from_s3(file_name, bucket_name)
    end

    def read_from_s3(file_name, bucket_name)
      Zlib.gunzip(
        s3_client.get_object(
          bucket: bucket_name,
          key: file_name
        ).body.read
      )
    end

    def db_connection_string
      config = ActiveRecord::Base.connection_db_config.configuration_hash

      host     = config[:host]     || config["host"]
      port     = config[:port]     || config["port"] || 5432
      database = config[:database] || config["database"]
      username = config[:username] || config["username"]
      password = config[:password] || config["password"]

      if username && password
        "postgres://#{username}:#{password}@#{host}:#{port}/#{database}"
      else
        "postgres://#{host}:#{port}/#{database}"
      end
    end

    def s3_client
      Aws::S3::Client.new(
        region: "us-east-1",
        credentials: s3_credentials
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
