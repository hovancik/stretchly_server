class App::V2::HomeController < ApplicationController
  def show
    redirect_to app_v2_sync_path if logged_in?
  end
end
