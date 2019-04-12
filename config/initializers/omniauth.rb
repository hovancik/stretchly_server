Rails.application.config.middleware.use OmniAuth::Builder do
  provider :patreon, ENV['PATREON_CLIENT_ID'], ENV['PATREON_CLIENT_SECRET'],
    path_prefix: '/app/auth', scope: 'users'
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], path_prefix: '/app/auth', scope: 'user'
end
