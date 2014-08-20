class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  # Line 12 is because Line 13 overrides current_user.
  # This is due to our API needs. I leave this here
  # because certain gems probably interface directly with
  # ApplicationController. In general, we use ApiController instead of
  # ApplicationController.
  #
  # TODO: Return when the product is farther along and decide if we should
  # keep this or ever use this. - David
  alias_method :devise_current_user, :current_user
  include SessionHelper
end
