module SessionHelper
  
  def current_user
    
    return @current_user if @current_user

    potential_user = User.find_by(external_id: params[:user_id])

    return nil unless potential_user
    
    auth_tokens = potential_user.authentication_tokens.map(&:token)
    
    auth_tokens.each do |auth_token|
      if Devise.secure_compare(auth_token, params[:auth_token])
        return @current_user = potential_user
      end
    end
    
    nil
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  def ensure_current_user!
    unless signed_in?
      render status: :unauthorized,
             json: { errors: [ "Gatekeeper required" ] }
    end
  end    
end