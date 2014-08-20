class ApiController < ActionController::API
  include SessionHelper

  respond_to :json
  before_action :ensure_current_user!
end