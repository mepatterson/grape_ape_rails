GrapeApeRails.configure do |config|
  config.app_name = "titan"
  config.organization_name = "monkeyworks"
  config.api_secret_key = "eb29e6a98f5e2fe8baa171bad1661d97f8bc68106026db58b153d8abaf843a87"
  # config.api_header_security_enabled = true
  # config.api_security_algorithm = "sha256"
  # config.security_envelope_debug = false
  config.available_locales = %i[ en jp es ]
end

# Subscribe to grape request and log with Rails.logger
ActiveSupport::Notifications.subscribe('grape.request') do |name, starts, ends, notification_id, payload|
  api_version = payload[:api_version] ? "[#{payload[:api_version]}]" : nil
  Rails.logger.info "[API]%s %s %s (%.3f ms) -> %s %s" % [
    api_version,
    payload[:request_method],
    payload[:request_path],
    (ends-starts)*1000,
    (payload[:response_status] || "error"),
    payload[:params] ? "| #{payload[:params].inspect}" : ""
  ]
end
