class Api::V1::SessionsController < ApiController
  
  skip_before_filter :ensure_current_user!, only: [:create]
  
  def create
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.valid_password?(params[:user][:password])
      login!(@user)
    
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
    logout!(@current_user)
    head :no_content
  end
end