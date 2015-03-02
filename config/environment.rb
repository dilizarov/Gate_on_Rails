# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Constants that aren't a secret but are to be used throughout.

POST_CREATED_NOTIFICATION    = 42
COMMENT_CREATED_NOTIFICATION = 126
POST_LIKED_NOTIFICATION      = 168
COMMENT_LIKED_NOTIFICATION   = 210
GENERATED_GATES_NOTIFICATION = 252