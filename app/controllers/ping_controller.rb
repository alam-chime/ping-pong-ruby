class PingController < ApplicationController
  def pong
    render plain: "pong - #{Time.now}"
  end
end
