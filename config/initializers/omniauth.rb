Rails.application.config.middleware.use OmniAuth::Builder do
  provider :patreon, ENV['PATREON_CLIENT_ID'], ENV['PATREON_CLIENT_SECRET'],
    path_prefix: '/app/auth', scope: 'users'
  provider :patreon, ENV['PATREON_CLIENT_ID'], ENV['PATREON_CLIENT_SECRET'],
    path_prefix: '/app/v1/auth', scope: 'users'
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'],
    path_prefix: '/app/auth', scope: 'read:user'
  provider :github, ENV['GITHUB_CLIENT_ID_V1'], ENV['GITHUB_CLIENT_SECRET_V1'],
    path_prefix: '/app/v1/auth', scope: 'read:user'
end
