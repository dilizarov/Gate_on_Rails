class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  rescue_from CanCan::AccessDenied do |exception|
    render status: :unauthorized,
           json: { success: false,
                   info: exception.message }
  
  # current_user is overridden by line 6
  alias_method :devise_current_user, :current_user
  include SessionHelper
end
