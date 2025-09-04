require_relative "boot"

require "rails/all"
require "logger"
require "json"
require "time"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pya
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es]

    config.allow_magic_verification_code = (Rails.env.development? || ENV["REVIEW_APP"] == "true")
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #
    config.email_url =
      if ENV["REVIEW_APP"] == "true"
        "https://demo.fileyourstatetaxes.org"
      elsif Rails.env.production?
        "https://www.fileyourstatetaxes.org"
      else
        "http://localhost:3000"
      end

    config.log_formatter = proc do |_, time, _, msg|
      if msg.is_a?(Hash)
        msg[:time] = time.utc.iso8601
        msg.to_json << "\n"
      else
        {time: time.utc.iso8601, message: msg.to_s}.to_json << "\n"
      end
    end

    config.colorize_logging = false

    logger = Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
end
