class HomeController < ApplicationController
  def index
    @channels = Channel.all
  end
end
