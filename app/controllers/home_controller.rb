# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_admin!

  def index; end

  def issue
    @device = Device.find_by barcode: params[:issue_device]
    @issuer = Issuer.find_by barcode: params[:issue_issuer]

    @errors = @device.issue to: @issuer

    respond_to do |format|
      if @device.save && @errors.empty?
        format.json { render json: { form: 'issue_form', result: 'success' } }
      else
        @errors += @device.errors.full_messages
        format.json do
          render json: { form: 'issue_form', result: 'error', errors: @errors },
                 status: :bad_request
        end
      end
    end
  end

  def return
    @device = Device.find_by barcode: params[:return_device]

    @errors = @device.return

    respond_to do |format|
      if @device.save && @errors.empty?
        format.json { render json: { form: 'return_form', result: 'success' } }
      else
        @errors += @device.errors.full_messages

        format.json do
          render json: { form: 'return_form', result: 'error', errors: @errors },
                 status: :bad_request
        end
      end
    end
  end
end
