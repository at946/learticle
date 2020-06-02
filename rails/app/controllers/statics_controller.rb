class StaticsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:top]

  def top
  end

  def tos
  end

  def pp
  end
end