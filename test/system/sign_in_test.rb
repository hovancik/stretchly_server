require "application_system_test_case"

class SignInTest < ApplicationSystemTestCase
  test "visiting the public home page" do
    visit root_path

    assert_selector "h1", text: "Love your Stretchly?"
    assert_link "Become a contributor", href: "https://hovancik.net/stretchly/sponsor/"
  end

  %w[github patreon].each do |provider|
    test "signing in with #{provider} and logging out" do
      user = sign_in(provider: provider)

      assert user.manual_contributor
      assert_selector "h1", text: "Thank you!"
      assert_selector "a", text: "Contributor Preferences"

      click_button "Logout"

      assert_current_path app_v1_root_path
      connect_stretchly
      assert_button "Continue with Github", disabled: true
      assert_no_button "Logout"
      assert_no_link "Sync Preferences"
    end
  end

  test "anonymous users must sign in before syncing" do
    visit app_v1_sync_path

    assert_current_path app_v1_root_path
    connect_stretchly
    assert_button "Continue with Github", disabled: true
    assert_no_selector "h1", text: "Sync Preferences"
  end
end
