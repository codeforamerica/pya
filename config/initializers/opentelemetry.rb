require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"
require 'opentelemetry-exporter-otlp'
OpenTelemetry::SDK.configure do |c|
  c.service_name = "pya"
  c.use_all
end

begin
  require "opentelemetry/propagator/xray"
  OpenTelemetry.propagation = OpenTelemetry::Context::Propagation.build do |b|
    b.text_map_propagator = OpenTelemetry::Propagator::XRay::TextMapPropagator.new
  end
rescue LoadError
end
