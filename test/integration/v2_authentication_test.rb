require "test_helper"

class V2AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @previous_test_mode = OmniAuth.config.test_mode
    @previous_mock_auth = OmniAuth.config.mock_auth.dup
    OmniAuth.config.test_mode = true
    %w[github patreon].each do |provider|
      OmniAuth.config.add_mock(provider.to_sym, uid: "new-v2-user")
    end
  end

  teardown do
    OmniAuth.config.test_mode = @previous_test_mode
    OmniAuth.config.mock_auth = @previous_mock_auth
  end

  %w[github patreon].each do |provider|
    test "v2 #{provider} login creates an account and goes directly to Sync" do
      get "/app/v2/auth/#{provider}"
      assert_difference "User.count", 1 do
        follow_redirect!
      end
      assert_redirected_to app_v2_sync_path
      follow_redirect!
      assert_response :success
      assert_select "h1", "Sync Preferences"
    end

    test "v2 #{provider} authorization sends the provider its own callback URL" do
      OmniAuth.config.test_mode = false
      get "/app/v2/auth/#{provider}"

      assert_response :redirect
      query = Rack::Utils.parse_query(URI.parse(response.location).query)
      assert_equal "http://www.example.com/app/v2/auth/#{provider}/callback", query['redirect_uri']
    end
  end

  test "an older client overwriting a backup clears its recorded Stretchly version" do
    get "/app/v2/auth/github"
    follow_redirect!
    assert_redirected_to app_v2_sync_path

    post settings_path, as: :json, params: { setting: { data: { language: "en" }, stretchly_version: "1.23.0" } }
    assert_response :success
    get settings_path(format: :json)
    assert_response :success
    assert_equal "1.23.0", response.parsed_body.fetch("stretchly_version")

    post settings_path, as: :json, params: { setting: { data: { language: "fr" } } }
    assert_response :success
    get settings_path(format: :json)
    assert_response :success
    assert_equal({ "language" => "fr" }, response.parsed_body.fetch("data"))
    assert_nil response.parsed_body.fetch("stretchly_version")
  end

  %w[/app /app/v1].each do |prefix|
    test "#{prefix} login keeps its landing page even with a v2 origin" do
      get "#{prefix}/auth/github", params: { origin: app_v2_sync_path }
      follow_redirect!

      assert_redirected_to prefix
    end
  end
end
