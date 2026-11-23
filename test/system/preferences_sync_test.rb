require "application_system_test_case"

class PreferencesSyncTest < ApplicationSystemTestCase
  test "a v2 user without contributor status can create and update a preference backup" do
    user = sign_in(v2: true)

    assert_text "Remote Preferences, never backed up"
    assert_no_button "Restore"
    assert_selector "#settings h2", text: "miniBreakInterval"

    click_button "Backup"
    connect_stretchly

    assert_text "Your Local and Remote preferences are the same."
    assert_equal LOCAL_PREFERENCES, user.reload.setting.data
    assert_button "Restore"

    updated_preferences = LOCAL_PREFERENCES.merge("miniBreakInterval" => 900_000)
    page.execute_script(
      "sessionStorage.setItem('stretchlySystemPreferences', JSON.stringify(arguments[0]))",
      updated_preferences
    )
    click_link "Refresh Data"
    connect_stretchly
    assert_selector "#settings h2", text: "miniBreakInterval"

    click_button "Backup"
    connect_stretchly

    assert_text "Your Local and Remote preferences are the same."
    assert_equal updated_preferences, user.reload.setting.data
    assert_equal 1, Setting.where(user: user).count
    assert_no_javascript_errors
  end

  test "a v2 user can restore remote preferences to Stretchly" do
    user = sign_in(v2: true)
    remote_preferences = LOCAL_PREFERENCES.merge("miniBreakInterval" => 900_000)
    user.create_setting!(data: remote_preferences)

    click_link "Refresh Data"
    connect_stretchly
    within "#settings .box", text: "miniBreakInterval" do
      assert_selector ".has-text-primary", text: "600000"
      assert_selector ".has-text-info", text: "900000"
    end

    click_button "Restore"
    connect_stretchly

    assert_text "Your Local and Remote preferences are the same."
    assert_equal remote_preferences, page.evaluate_script(
      "JSON.parse(sessionStorage.getItem('stretchlySystemPreferences'))"
    )
    assert_equal remote_preferences, user.reload.setting.data
    assert_no_javascript_errors
  end

  test "logged-out v2 users cannot revisit preference sync" do
    sign_in(v2: true)
    assert_selector "#settings h2", text: "miniBreakInterval"

    click_button "Logout"

    assert_current_path app_v2_root_path
    connect_stretchly
    assert_button "Continue with Github", disabled: true

    visit app_v2_sync_path
    assert_current_path app_v2_root_path
    assert_no_button "Logout"
  end
end
