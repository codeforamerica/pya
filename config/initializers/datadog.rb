Datadog.configure do |c|
  c.service = 'getyourrefund-app'
  c.env = Rails.env
  enable_tracing = Rails.env.staging? || Rails.env.production?
  c.tracing.enabled = enable_tracing
  if enable_tracing
    c.tracing.instrument :rails
    c.tracing.instrument :aws
    c.tracing.instrument :delayed_job
    c.tracing.instrument :http
  end
end
