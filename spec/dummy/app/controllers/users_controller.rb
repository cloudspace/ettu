class UsersController < ApplicationController

  # GET /users
  def index
    user = User.instance
    @user = fresh_when user
  end

end
