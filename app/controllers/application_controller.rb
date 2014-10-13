class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
     
  def devise_current_user
     @devise_current_user ||= warden.authenticate(:scope => :user)
  end
  
  include SessionHelper
end
