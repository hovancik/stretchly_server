class SettingsController < ApplicationController
  prepend_before_action :require_login

  def index
    render json: current_user.setting.as_json
  end

  def create
    if current_user.setting.present?
      current_user.setting.update(setting_params)
    else
      current_user.build_setting(setting_params).save
    end
  end

  private

  def require_login
    head :unauthorized unless logged_in?
  end

  def setting_params
    # A client that omits its version replaces the previous backup's version too.
    params.require(:setting).permit(:stretchly_version, data: {}).reverse_merge(stretchly_version: nil)
  end
end
