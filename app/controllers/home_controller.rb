# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :authenticate_admin!, only: :index

  def index
    redirect_to new_session_path(Admin) unless admin_signed_in?
  end

  def issuer_info
    # @type [Issuer]
    @issuer = Barcode.find_by!(code: params[:issue_to]).issuer!

    render 'home/issuer_info', layout: false
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    show_text_errors(e)
  end

  def issue
    # @type [Issuer]
    @issuer = Barcode.find_by!(code: params[:issuer]).issuer!
    # @type [Device]
    @device = Barcode.find_by!(code: params[:issue_with]).device!

    validate_allowance unless params[:override_allowance] == 'override'

    @device.issue @issuer
    @device.save!

    render plain: "Issued #{@device.to_param} to #{@issuer.to_param}"
  rescue ActiveRecord::ActiveRecordError => ex
    show_text_errors(ex)
  end

  def return
    # @type [Device]
    @device = Barcode.find_by!(code: params[:device]).device!
    @device.return
    @device.save!

    render plain: "Returned #{@device.to_param}"
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => ex
    show_text_errors(ex)
  end

  private

  def validate_allowance
    return if @issuer.allowed_another_device?

    raise ActiveRecord::RecordNotSaved,
          "Issuer allowance already #{@issuer.allowance_state}"
  end

  # @param exception [Exception]
  def show_text_errors(exception)
    status = case exception
             when ActiveRecord::RecordNotFound    then :not_found
             when ActiveRecord::RecordNotSaved    then :forbidden # REVIEW
             when ActiveRecord::RecordInvalid     then :not_acceptable # REVIEW
             when ActiveRecord::ActiveRecordError then :not_acceptable # REVIEW
             end
    render plain: exception.message, status: status
  end
end
