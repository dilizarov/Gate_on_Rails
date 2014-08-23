class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token,
                     if: Proc.new { |c| c.request.format == 'application/json' }
  
  respond_to :json
  before_action :ensure_current_user!
end