require "application_system_test_case"

class PreferencesSyncTest < ApplicationSystemTestCase
  test "a non-contributor on the new app can create and update a preference backup" do
    user = sign_in
    user.update!(contributor: false, manual_contributor: false)
    visit app_v1_root_path
    connect_stretchly
    assert_link "Sync Preferences"
    click_link "Sync Preferences"
    connect_stretchly

    assert_text "Remote Preferences, never backed up"
    assert_no_selector "a", text: "Restore"
    assert_selector "#settings h2", text: "miniBreakInterval"

    find("a", text: "Backup", exact_text: true).click
    connect_stretchly

    assert_text "Your Local and Remote preferences are the same."
    assert_equal LOCAL_PREFERENCES, user.reload.setting.data
    assert_selector "a", text: "Restore"

    updated_preferences = LOCAL_PREFERENCES.merge("miniBreakInterval" => 900_000)
    page.execute_script(
      "sessionStorage.setItem('stretchlySystemPreferences', JSON.stringify(arguments[0]))",
      updated_preferences
    )
    click_link "Refresh Data"
    connect_stretchly
    assert_selector "#settings h2", text: "miniBreakInterval"

    find("a", text: "Backup", exact_text: true).click
    connect_stretchly

    assert_text "Your Local and Remote preferences are the same."
    assert_equal updated_preferences, user.reload.setting.data
    assert_equal 1, Setting.where(user: user).count
  end

  test "the new app can restore remote preferences to Stretchly" do
    user = sign_in
    remote_preferences = LOCAL_PREFERENCES.merge("miniBreakInterval" => 900_000)
    user.create_setting!(data: remote_preferences)

    click_link "Sync Preferences"
    connect_stretchly
    within "#settings .box", text: "miniBreakInterval" do
      assert_selector ".has-text-primary", text: "600000"
      assert_selector ".has-text-info", text: "900000"
    end

    find("a", text: "Restore", exact_text: true).click
    connect_stretchly

    assert_text "Your Local and Remote preferences are the same."
    assert_equal remote_preferences, page.evaluate_script(
      "JSON.parse(sessionStorage.getItem('stretchlySystemPreferences'))"
    )
    assert_equal remote_preferences, user.reload.setting.data
  end

  test "logged-out users on the new app cannot revisit preference sync" do
    sign_in
    click_link "Sync Preferences"
    connect_stretchly
    assert_selector "#settings h2", text: "miniBreakInterval"

    click_button "Logout"

    assert_current_path app_v1_root_path
    connect_stretchly
    assert_button "Continue with Github", disabled: true

    visit app_v1_sync_path
    assert_current_path app_v1_root_path
    assert_no_button "Logout"
  end
end
