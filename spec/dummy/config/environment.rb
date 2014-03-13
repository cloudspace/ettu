# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dummy::Application.initialize!

Dummy::Application.configure do
  config.assets.digest = true
end
