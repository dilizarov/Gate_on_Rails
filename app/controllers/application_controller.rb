class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
     
  # current_user is overridden by line 6
  alias_method :devise_current_user, :current_user
  include SessionHelper
end
