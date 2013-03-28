class UsersController < ApplicationController
  before_filter :require_user, except: [:welcome]

  def welcome
  end

  def index
    @home_active = true
  end
end
