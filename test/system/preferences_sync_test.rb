require "application_system_test_case"

class PreferencesSyncTest < ApplicationSystemTestCase
  %w[Backup Restore].each do |action|
    test "expired login during #{action} returns to v2 login and preserves preferences" do
      user = sign_in(v2: true)
      saved = { "language" => "fr" }
      user.create_setting!(data: saved)
      click_link "Refresh Data"
      connect_stretchly
      assert_selector "#settings h2", text: "language"

      page.driver.browser.manage.delete_all_cookies
      click_button action

      assert_current_path app_v2_root_path
      assert_equal saved, user.reload.setting.data
      assert_equal LOCAL_PREFERENCES, page.evaluate_script(
        "JSON.parse(sessionStorage.getItem('stretchlySystemPreferences'))"
      )
      assert_no_javascript_errors
    end
  end

  test "a rejected backup clears the loading state" do
    user = sign_in(v2: true)
    assert_selector "#settings h2", text: "language"
    page.execute_script("document.querySelector('[name=csrf-token]').content = 'invalid'")

    loading = page.evaluate_async_script(<<~JS)
      const done = arguments[0]
      const sync = window.syncControllerInstance
      sync.backup().then(() => done(sync.element.classList.contains('is-loading')))
    JS
    assert_equal false, loading
    assert_current_path app_v2_sync_path
    assert_nil user.reload.setting
  end

  test "Sync displays markup in preference names and values as text" do
    user = sign_in(v2: true)
    key = "<b>message</b>"
    page.execute_script(
      "sessionStorage.setItem('stretchlySystemPreferences', JSON.stringify(arguments[0]))",
      { key => "<i>Look away</i>" }
    )
    user.create_setting!(data: { key => "<em>Stretch</em>" })

    click_link "Refresh Data"
    connect_stretchly

    within "#settings .box" do
      assert_selector "h2", exact_text: key
      assert_selector ".has-text-primary", exact_text: '"<i>Look away</i>"'
      assert_selector ".has-text-info", exact_text: '"<em>Stretch</em>"'
      assert_no_selector "b, i, em", visible: :all
    end
  end

  test "Sync shows a local preference missing from the backup" do
    user = sign_in(v2: true)
    page.execute_script(
      "sessionStorage.setItem('stretchlySystemPreferences', JSON.stringify(arguments[0]))",
      { "language" => "en", "theme" => "dark" }
    )
    user.create_setting!(data: { "theme" => "dark" })

    click_link "Refresh Data"
    connect_stretchly

    assert_selector "#settings .box", count: 1
    within "#settings .box" do
      assert_selector "h2", exact_text: "language"
      assert_selector ".has-text-primary", exact_text: '"en"'
      assert_selector ".has-text-info", exact_text: "undefined"
    end
  end

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
