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
  before_action :ensure_current_user!
end