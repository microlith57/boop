# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  def issue
    authenticate_admin!

    @device = Device.find_by barcode: params[:device]
    @issuer = Issuer.find_by barcode: params[:issuer]

    @device.issue to: @issuer
    @device.save
  end

  def return
    authenticate_admin!

    @device = Device.find_by barcode: params[:device]

    @device.return
    @device.save
  end
end
