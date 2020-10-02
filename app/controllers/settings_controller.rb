class SettingsController < ApplicationController

  def index
    render json: current_user&.setting.as_json
  end

  def create
    if current_user.setting.present?
      current_user.setting.update(setting_params)
    else
      current_user.build_setting(setting_params).save
    end
  end

  private

  def setting_params
    params.require(:setting).permit(data: {})
  end
end
