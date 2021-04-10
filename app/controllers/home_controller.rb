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
    show_text_errors exc
  end

  # @todo move to helper
  # @param exception [Exception]
  def show_text_errors(exception)
    status = case exception
             when ActiveRecord::RecordNotFound    then :not_found
             when ActiveRecord::RecordNotSaved    then :forbidden # REVIEW
             when ActiveRecord::RecordInvalid,
                  ActiveRecord::ActiveRecordError then :not_acceptable # REVIEW
             end
    render plain: exception.message, status: status
  end
end
