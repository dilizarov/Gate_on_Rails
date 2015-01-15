class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token,
                     if: Proc.new { |c| c.request.format == 'application/json' }
                         
  respond_to :json
  
  def create
    build_resource(sign_up_params)
    
    if resource.save
      resource.login!
      resource.sync_device(params[:device]) if params[:device]
      
      render status: 200,
             json: resource,
             serializer: CurrentUserSerializer,
             root: "user",
             meta: { success: true,
                     info: "Registered" }
    else
      render status: :unprocessable_entity,
             json: { errors: resource.errors.full_messages }
    end
  end
  
  private
  
  # Had to change a devise solution. Devise has been really flaky for me during
  # this project. I might just scrape it all together and use my own solutions
  # while borrowing from the Devise source-code for a few helper methods I use.
  # - David
  def sign_up_params
    params.require(:user).permit(:name, :email, :password)
  end
end