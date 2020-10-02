class App::V1::SyncController < ApplicationController
  def show
    redirect_to app_v1_root_path unless current_user
  end
end
