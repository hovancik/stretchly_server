class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :contributor?

  private

  def current_user
    @current_user ||= User.find_by(auth_token: session[:auth_token]) \
      if session[:auth_token]
  end

  def logged_in?
    current_user != nil
  end

  def contributor?
    logged_in? && current_user.contributor
  end

end
