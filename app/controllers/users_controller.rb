class UsersController < ApplicationController
  
  skip_before_filter :verify_authenticity_token,
                     if: Proc.new { |c| c.request.format == 'application/json' },
                     only: :reset_password
  
  def send_forgot_password_email
    @user = User.find_by(email: params[:email])
    
    if @user
      @user.reset_password_token = Devise.friendly_token
      @user.save
      
      UserNotifier.send_forgot_password_email(@user).deliver
      
      head :no_content
    else
      render status: :not_found,
             json: { errors: [ "Email not registered" ] }
    end
  end
  
  def reset_password
    unless params[:token] && params[:password] && params[:password_confirmation]
      render status: :unprocessable_entity,
             json: { errors: [ "Your password or password confirmation was blank" ] }
    
      return
    end
    
    @user = User.find_by_reset_password_token(reset_password_token: params[:token])
    
    if @user && @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      head :ok
    else
      render status: :unprocessable_entity,
             json: { errors: @user.errors.full_messages }
    end
  end
  
  def reset_password_page
    
  end
end
