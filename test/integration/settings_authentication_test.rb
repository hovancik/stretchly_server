require "test_helper"

class SettingsAuthenticationTest < ActionDispatch::IntegrationTest
  test "signed-out reads and writes return unauthorized, even with a stale CSRF token" do
    previous = ApplicationController.allow_forgery_protection
    ApplicationController.allow_forgery_protection = true
    get settings_path(format: :json)
    assert_response :unauthorized

    post settings_path, as: :json, params: { setting: { data: { language: "en" } } },
      headers: { "X-CSRF-Token" => "expired" }
    assert_response :unauthorized
  ensure
    ApplicationController.allow_forgery_protection = previous
  end
end
