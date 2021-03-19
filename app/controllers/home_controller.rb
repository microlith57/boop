# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :authenticate_admin!, only: :index

  def index
    redirect_to new_session_path(Admin) unless admin_signed_in?

    @q = Barcode.ransack
  end

  def borrower_info
    # @type [Borrower]
    @borrower = Barcode.find_by!(code: params[:issue_to]).borrower!

    render 'home/borrower_info', layout: false
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => exc
    show_text_errors(exc)
  end

  def issue
    # @type [Borrower]
    @borrower = Barcode.find_by!(code: params[:borrower]).borrower!
    # @type [Device]
    @device = Barcode.find_by!(code: params[:issue_with]).device!

    validate_allowance unless params[:"override-allowance"] == 'override'

    @device.issue @borrower
    @device.save!

    render plain: "Issued #{@device.to_param} to #{@borrower.to_param}"
  rescue ActiveRecord::ActiveRecordError => exc
    show_text_errors(exc)
  end

  # :reek:TooManyStatements
  # :reek:DuplicateMethodCall
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def return
    # @type [Loan]
    @loan = Barcode.find_by!(code: params[:device]).device!.current_loan
    if @loan.blank?
      raise ActiveRecord::RecordNotFound, 'Device already returned'
    end

    response = 'Success'
    if @loan.overdue?
      # TODO: Use `pluralize` instead
      response += if @loan.days_overdue == 1
                    " (#{@loan.days_overdue} day overdue)"
                  else
                    " (#{@loan.days_overdue} days overdue)"
                  end
    end

    @loan.return
    @loan.save!

    render plain: response
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => exc
    show_text_errors(exc)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def validate_allowance
    return if @borrower.allowed_another_device?

    raise ActiveRecord::RecordNotSaved,
          "Borrower allowance already #{@borrower.allowance_state}"
  end

  # @param exception [Exception]
  # REVIEW: Should we send whole stack trace?
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
