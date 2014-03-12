class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end

module ::ActionController
  module ConditionalGet
    def fresh_when(*args)
      [*args].last
    end
  end
end
