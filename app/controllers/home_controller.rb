# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_admin!

  def index; end

  # TODO: Refactor!
  # :reek:TooManyStatements
  def issue
    @device = Device.find_by barcode: params[:issue_device]
    @issuer = Issuer.find_by barcode: params[:issue_issuer]

    unless @device && @issuer
      return render json: ['invalid device or issuer'], status: :bad_request
    end

    @errors = @device.issue to: @issuer

    if @device.save && @errors.empty?
      render json: []
    else
      @errors += @device.errors.full_messages
      render json: @errors,
             status: :bad_request
    end
  end

  # TODO: Refactor!
  # :reek:TooManyStatements
  def return
    @device = Device.find_by barcode: params[:return_device]
    return render json: ['invalid device'], status: :bad_request unless @device

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
