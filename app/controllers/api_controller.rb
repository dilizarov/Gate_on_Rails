class ApiController < ActionController::API
  respond_to :json
  
  include SessionHelper
end