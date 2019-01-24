module App
  class SessionsController < ApplicationController
    def create
      user = User.find_or_create_from_auth_hash(auth_hash)
      session[:auth_token] = user.auth_token
      SetPatreonContributorsJob.perform_later
      redirect_to app_root_path
    end

    def destroy
      session[:auth_token] = nil
      redirect_to app_root_path
    end

    private

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
