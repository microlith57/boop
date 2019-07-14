# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_admin!

  def index; end

  def issue
    @device = Device.find_by barcode: params[:issue_device]
    @issuer = Issuer.find_by barcode: params[:issue_issuer]

    raise ActiveRecord::RecordNotFound unless @device && @issuer

    @errors = @device.issue to: @issuer

    if @device.save && @errors.empty?
      render json: []
    else
      @errors += @device.errors.full_messages
      render json: @errors,
             status: :bad_request
    end
  end

  def return
    @device = Device.find_by barcode: params[:return_device]
    raise ActiveRecord::RecordNotFound unless @device

    if @device
      @errors = @device.return

      if @device.save && @errors.empty?
        render json: []
      else
        @errors += @device.errors.full_messages
        render json: @errors,
               status: :bad_request

      end
    else
      render json: ['no such device'],
             status: :not_found
    end
  end
end
