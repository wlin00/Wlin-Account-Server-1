class HomeController < ApplicationController
  def index
    render json: {
      message: "Welcome to Wlin Account!"
    }
  end
end
