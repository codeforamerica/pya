# Basic packages for your application
require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"
require 'faraday'

# Add imports for OTel components into the application
require "opentelemetry-api"
require "opentelemetry-exporter-otlp"
require "opentelemetry-sdk"

# Import the gem containing the AWS X-Ray for OTel Ruby ID Generator and propagator
require "opentelemetry-propagator-xray"

# Configure OpenTelmetry Ruby SDK
OpenTelemetry::SDK.configure do |c|
  # Set the service name to identify your application in the X-Ray backend service map
  c.service_name = "pya"

  c.span_processors = [
    # Use the BatchSpanProcessor to send traces in groups instead of one at a time
    Trace::Export::BatchSpanProcessor.new(
      # Use the default OLTP Exporter to send traces to the ADOT Collector
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        # The ADOT Collector is running as a sidecar and listening on port 4318
        "http://localhost:4318"
      )
    )
  ]

  # The X-Ray ID Generator generates spans with X-Ray backend compliant IDs
  c.id_generator = OpenTelemetry::Propagator::XRay::IDGenerator

  # The X-Ray Propagator injects the X-Ray Tracing Header into downstream calls
  c.propagators = [OpenTelemetry::Propagator::XRay::TextMapPropagator.new]
end
