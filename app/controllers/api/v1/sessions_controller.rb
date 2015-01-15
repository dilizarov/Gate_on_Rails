class Api::V1::SessionsController < ApiController
  
  skip_before_filter :ensure_current_user!, only: [:create]
  
  def create
    p "Hi"
    @user = User.find_by(email: params[:user][:email])
    p "Hi"
    if @user && @user.valid_password?(params[:user][:password])
      p "Hi"
      @user.login!
      p "Hi"
      @user.sync_device(params[:device]) if params[:device]
      
      puts @user.auth_token
    
      render status: 200,
             json: @user,
             serializer: CurrentUserSerializer,
             root: "user",
             meta: { success: true, 
                     info: "Logged in" }             
    else
      render status: :unprocessable_entity,
             json: { errors: ["Incorrect email or password"] }
    end
  end
  
  def destroy
    current_user.unsync_device(params[:device]) if params[:device]
    current_user.logout!(params[:auth_token])
    
    head :no_content
  end
  
  
end