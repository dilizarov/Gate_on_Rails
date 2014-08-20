module SessionHelper
  
  def current_user
    @current_user ||= User.find_by(authentication_token: params[:auth_token])
  end
  
end