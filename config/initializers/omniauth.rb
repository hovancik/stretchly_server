Rails.application.config.middleware.use OmniAuth::Builder do
  provider :patreon, ENV['PATREON_CLIENT_ID'], ENV['PATREON_CLIENT_SECRET'], path_prefix: '/app/auth'
end
