module SessionHelper
  
  def current_user
    @current_user ||= User.find_by(authentication_token: params[:auth_token])
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  def ensure_current_user!
    unless signed_in?
      render status: 401,
             json: { success: true,
                     info: "Invalid user",
                     data: {} }
    end
  end
    
end