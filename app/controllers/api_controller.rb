class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token,
                     if: Proc.new { |c| c.request.format == 'application/json' }
  
  rescue_from CanCan::AccessDenied do |exception|
    render status: :unauthorized,
           json: { errors: [ "Gatekeeper, you are not authorized to perform this action" ] }
  end
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    head :not_found
  end
  
  respond_to :json
  
  before_action :authenticate_api_key!
  before_action :ensure_current_user!
  
  def authenticate_api_key!
    if params[:api_key] != ENV["ANDROID_API_KEY"]
      render status: 401,
             json: { errors: [ "Gatekeeper, that is not a valid API key" ] }
    end
  end
end