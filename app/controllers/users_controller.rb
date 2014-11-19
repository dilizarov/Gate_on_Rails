class UsersController < ApplicationController
  
  def forgot_password
    @user = User.find_by(email: params[:email])
    
    if @user
      @user.reset_password_token = Devise.friendly_token
      @user.save
      
      UserNotifier.send_forgot_password_email(@user).deliver
      
      head :no_content
    else
      head :not_found
    end
  end
  
  def reset_password
    
  end
  
end
