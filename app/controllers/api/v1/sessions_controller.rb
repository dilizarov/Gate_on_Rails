class Api::V1::SessionsController < ApiController
  
  skip_before_filter :ensure_current_user!, only: [:create]
  
  def create
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.valid_password?(params[:user][:password])
      login(@user)
    
      user_hash = {
        email:       @user.email,
        name:        @user.name,
        auth_token:  @user.authentication_token,
        external_id: @user.external_id,
        created_at:  @user.created_at
      }
    
      render status: 200,
             json: { success: true,
                     info: "Logged in",
                     data: { user: user_hash } }
    else
      render status: :unprocessable_entity,
             json: { success: false,
                     info: "Incorrect email or password",
                     data: {} }
    end
  end
  
  def destroy
    logout(@current_user)
    
    render status: 200,
           json: { success: true,
                   info: "Logged out",
                   data: {} }
  end
end