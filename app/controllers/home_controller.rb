# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_admin!

  def index; end

  def issue
    @device = Device.find_by! barcode: params[:issue_device]
    @issuer = Issuer.find_by! barcode: params[:issue_issuer]
    validate_allowance

    @device.issue @issuer
    return if @device.save

    render json: @device.errors.full_messages, status: :bad_request
  end

  def return
    @device = Device.find_by! barcode: params[:return_device]
    @device.return
    return if @device.save

    render json: @device.errors, status: :bad_request
  end

  private

  def validate_allowance
    override = params[:override_allowance]
    return if override || @issuer.allowance >= (@issuer.devices.length + 1)

    @device.errors.add(:issuer, "can't have a full allowance")
  end
end
