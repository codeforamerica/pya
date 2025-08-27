# config/initializers/datadog_logging.rb
require "logger"
require "json"

Rails.application.configure do
  logger = Logger.new($stdout)

  logger.formatter = proc do |_, time, _, msg|
    if msg.is_a?(Hash)
      msg[:time] = time.utc.iso8601
      msg.to_json + "\n"
    else
      {time: time.utc.iso8601, message: msg.to_s}.to_json + "\n"
    end
  end

  config.logger = ActiveSupport::TaggedLogging.new(logger)
end
