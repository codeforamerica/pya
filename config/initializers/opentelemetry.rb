require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"
require 'opentelemetry-exporter-otlp'
OpenTelemetry::SDK.configure do |c|
  c.service_name = "pya"
  c.use_all
end
