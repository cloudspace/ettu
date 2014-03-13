class ApplicationController < ActionController::Base
  protect_from_forgery
end

module ::ActionController
  module ConditionalGet
    def fresh_when(*args)
      [*args].last
    end
  end
end
