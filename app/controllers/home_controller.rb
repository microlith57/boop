# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  def issue
    authenticate_admin!

    @device = Device.find_by barcode: params[:device]
    @issuer = Issuer.find_by barcode: params[:issuer]

    @device.issuer = @issuer
    @device.issued_at = Time.current
    if @device.save
      redirect_to root_path
    else
      render root_path
    end
  end

  def return
    authenticate_admin!

    @device = Device.find_by barcode: params[:device]

    @device.issuer = nil
    @device.issued_at = nil
    if @device.save
      redirect_to root_path
    else
      render root_path
    end
  end
end
