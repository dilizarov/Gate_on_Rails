module SessionHelper
  
  def current_user
    
    @current_user ||= User.find_by(external_id: params[:user_id])
    
    return nil unless @current_user && Devise.secure_compare(@current_user.authentication_token,
                                                             params[:auth_token])
                                                                               
    @current_user    
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  def ensure_current_user!
    unless signed_in?
      render status: 401,
             json: { success: true,
                     info: "Gatekeeper required",
                     data: {} }
    end
  end
  
  def login(model)
    model.authentication_token ||= Devise.friendly_token
    model.save
  end
  
  def logout(model)
    model.update_column(:authentication_token, nil)
  end
    
end