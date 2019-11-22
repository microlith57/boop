# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :authenticate_admin!, only: :index

  def index
    redirect_to new_session_path(Admin) unless admin_signed_in?
  end

  def issue
    # @type [Device]
    @device = Barcode.find_by!(code: params[:issue_device]).device!
    # @type [Issuer]
    @issuer = Barcode.find_by!(code: params[:issue_issuer]).issuer!
    validate_allowance

    @device.issue @issuer
    return if @device.save

    render json: @device.errors.full_messages, status: :bad_request
  end

  def return
    # @type [Device]
    @device = Barcode.find_by!(code: params[:return_device]).device!
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
