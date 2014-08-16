GrapeApeRails.configure do |config|
  config.organization_name = "monkeyworks"
  config.app_name = "titan"
  config.api_secret_key = "123456fakefakefake123456"
  # config.api_header_security_enabled = true
  # config.api_security_algorithm = "sha256"
  # config.api_header_security_uses_request_body = false
  config.security_envelope_debug = false
  config.available_locales = %i[ en jp es de ]
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
