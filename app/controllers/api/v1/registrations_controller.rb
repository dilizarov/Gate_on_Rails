class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token,
                     if: Proc.new { |c| c.request.format == 'application/json' }
                       
  before_action :configure_permitted_parameters
  
  respond_to :json
  
  def create
    build_resource(sign_up_params)
    
    if resource.save
      login(resource)
      
      render status: 200,
             json: resource,
             serializer: CurrentUserSerializer,
             root: "user",
             meta: { success: true,
                     info: "Registered" }
    else
      render status: :unprocessable_entity,
             json: { errors: resource.errors }
    end
  end
  
  private
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :email, :password, :password_confirmation)
    end
  end
end