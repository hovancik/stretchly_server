require "application_system_test_case"

class V2SignInTest < ApplicationSystemTestCase
  %w[github patreon].each do |provider|
    test "v2 signs in with #{provider} directly to Sync and can sign in again after logout" do
      user = sign_in(provider: provider, v2: true)

      assert_not user.contributor
      assert_not user.manual_contributor
      assert_selector "h1", text: "Sync Preferences"
      assert_selector "#settings h2", text: "miniBreakInterval"
      assert_no_text "contributor"
      assert_no_link "Contributor Preferences"
      assert page.evaluate_script("['setContributor', 'showContributorPreferences', 'openContriborSettings'].every(key => !(key in window.ElectronBridge))")
      assert_no_javascript_errors

      visit app_v2_root_path
      assert_current_path app_v2_sync_path
      connect_stretchly
      assert_button "Logout"

      click_button "Logout"
      assert_current_path app_v2_root_path
      connect_stretchly
      assert_no_button "Logout"
      assert_selector "h1", text: "Sync your preferences"
      assert_button "Continue with Github", disabled: true

      assert_no_difference "User.count" do
        find("[data-terms-target='checkbox']").check
        click_button "Continue with #{provider == 'github' ? 'Github' : 'Patreon'}"
        assert_current_path app_v2_sync_path
        connect_stretchly
        assert_button "Logout"
      end
      assert_no_javascript_errors
    end
  end

  test "anonymous v2 users must sign in before syncing" do
    visit app_v2_sync_path

    assert_current_path app_v2_root_path
    connect_stretchly
    assert_button "Continue with Github", disabled: true
    assert_button "Continue with Patreon", disabled: true
    assert_no_selector "h1", text: "Sync Preferences"
    assert_no_javascript_errors
  end
end
