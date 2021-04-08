# frozen_string_literal: true

require 'csv'

class LoansController < ApplicationController
  before_action :authenticate_admin!

  def index
    query = params[:q]

    @q = Loan.ransack query
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    result = @q.result.includes(:borrower, :device)

    respond_to do |format|
      format.html do
        @pagy, @loans = pagy(
          result,
          items: params[:limit] || Pagy::VARS[:items]
        )
      end
      format.csv do
        @loans = result
        data = CSV.generate(headers: true) do |csv|
          csv << %w[created_at returned_at borrower device]
          @loans.each do |loan|
            csv << [
              loan.created_at,
              loan.returned_at,
              loan.borrower.barcode.code,
              loan.device.barcode.code
            ]
          end
        end
        send_data data, filename: 'loans.csv'
      end
    end
  end

  def create
    # @type [Borrower]
    @borrower = Barcode.find_by!(code: params[:borrower]).borrower!
    # @type [Device]
    @device = Barcode.find_by!(code: params[:issue_with]).device!

    validate_allowance
    @device.issue @borrower
    @device.save!

    render plain: "Issued #{@device.to_param} to #{@borrower.to_param}"
  rescue ActiveRecord::ActiveRecordError => exc
    show_text_errors exc
  end

  def return
    # @type [Loan]
    @loan = Barcode.find_by!(code: params[:device]).device!.current_loan!

    response = 'Success'
    if @loan.overdue?
      days = @loan.days_overdue
      response += " (#{days} #{'day'.pluralize(days)} overdue)"
    end

    @loan.return
    @loan.save!

    render plain: response
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => exc
    show_text_errors exc
  end

  private

  # rubocop:disable Style/GuardClause
  def validate_allowance
    unless @borrower.allowed_another_device? || params[:override_allowance] == 'override'
      raise ActiveRecord::RecordNotSaved,
            "Borrower allowance already #{@borrower.allowance_state}"
    end
  end
  # rubocop:enable Style/GuardClause

  # @todo move to helper
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
