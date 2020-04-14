class App::V1::HomeController < ApplicationController
  def show
    @provider = params[:provider]
  end
end
