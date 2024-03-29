class Api::V1::SessionsController < ApiController
  
  skip_before_filter :ensure_current_user!, only: [:create]
  
  def create
    
    @user = User.find_by(email: params[:user][:email])
    
    if @user && @user.valid_password?(params[:user][:password])
      @user.login!
      @user.sync_device(params[:device]) if params[:device]
          
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
  
  def update_location
    current_user.auth_token.update_attributes(latitude: params[:lat], longitude: params[:long])    
      
    render status: :ok,
           json: { meta: { nearby_users_count: current_user.nearby_users_count } }
  end
  
  def destroy
    current_user.unsync_device(params[:device]) if params[:device]
    current_user.logout!(params[:auth_token])
    
    head :no_content
  end
  
  
end