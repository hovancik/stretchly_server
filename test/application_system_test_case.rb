require "test_helper"

ENV["MIN_STRETCHLY_VERSION"] ||= "1.6.0"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ActiveJob::TestHelper

  if ENV["SELENIUM_HOST"]
    Capybara.server_host = "0.0.0.0"
    Capybara.server_port = ENV.fetch("CAPYBARA_SERVER_PORT", "45678").to_i
    Capybara.app_host = ENV.fetch(
      "CAPYBARA_APP_HOST",
      "http://app:#{Capybara.server_port}"
    )

    driven_by :selenium,
              using: :headless_chrome,
              screen_size: [1400, 1400],
              options: {
                browser: :remote,
                url: "http://#{ENV["SELENIUM_HOST"]}:4444/wd/hub"
              }
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |chrome_options|
      chrome_options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"]
      chrome_options.add_argument("--no-sandbox") if ENV["CI"]
      chrome_options.add_argument("--disable-dev-shm-usage") if ENV["CI"]
    end
  end

  LOCAL_PREFERENCES = {
    "miniBreakInterval" => 600_000,
    "language" => "en",
    "microBreakIdeas" => [{ "text" => "Look away", "enabled" => true }]
  }.freeze

  setup do
    @previous_omniauth_test_mode = OmniAuth.config.test_mode
    @previous_mock_auth = OmniAuth.config.mock_auth.dup
    OmniAuth.config.test_mode = true

    # Exercise the real CSRF tokens used by preference backup requests.
    @previous_forgery_protection = ApplicationController.allow_forgery_protection
    ApplicationController.allow_forgery_protection = true
  end

  teardown do
    OmniAuth.config.test_mode = @previous_omniauth_test_mode
    OmniAuth.config.mock_auth = @previous_mock_auth
    ApplicationController.allow_forgery_protection = @previous_forgery_protection
  end

  def after_teardown
    # A fresh browser isolates cookies and desktop state, and avoids Capybara 3.40's
    # wildcard-origin reset, which current Chrome rejects.
    page.quit
  ensure
    super
  end

  private

  def sign_in(provider: "github")
    user = User.create!(provider: provider, uid: "system-test-user")
    OmniAuth.config.add_mock(provider.to_sym, uid: user.uid)

    visit app_v1_root_path(provider: provider)
    connect_stretchly

    button = "Continue with #{provider == 'github' ? 'Github' : 'Patreon'}"
    assert_button button, disabled: true
    find("[data-terms-target='checkbox']").check
    assert_button button, disabled: false

    assert_enqueued_jobs 2 do
      click_button button
      assert_current_path app_v1_root_path
      assert_button "Logout"
    end

    connect_stretchly
    assert_link "Sync Preferences"
    user
  end

  def connect_stretchly
    # The browser exercises the real JS and HTTP requests; only the desktop API is mocked.
    page.execute_script(<<~JS, LOCAL_PREFERENCES)
      if (!sessionStorage.getItem('stretchlySystemPreferences')) {
        sessionStorage.setItem('stretchlySystemPreferences', JSON.stringify(arguments[0]));
      }
      window.ElectronBridge = {
        stretchlyVersion: async () => '99.0.0',
        setContributor: () => {},
        showContributorPreferences: () => {},
        currentSettings: async () => JSON.parse(sessionStorage.getItem('stretchlySystemPreferences')),
        restoreRemoteSettings: async (settings) => {
          sessionStorage.setItem('stretchlySystemPreferences', JSON.stringify(settings));
        }
      };
    JS
  end

  def reconnect_after_reload
    assert_selector "[data-electron-target='loader']"
    connect_stretchly
  end
end
