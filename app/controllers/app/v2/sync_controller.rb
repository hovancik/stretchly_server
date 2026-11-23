class App::V2::SyncController < ApplicationController
  def show
    redirect_to app_v2_root_path unless logged_in?
  end
end
