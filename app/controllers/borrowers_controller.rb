# frozen_string_literal: true

require 'csv'

class BorrowersController < ApplicationController
  before_action :authenticate_admin!

  def index
    query = params[:q]

    if query && (
      bar = Barcode.find_by code: query[:name_or_code_or_email_cont]
    ) && bar.borrower?
      redirect_to bar.borrower
      return
    end

    @q = Borrower.ransack query
    @q.sorts = 'name asc' if @q.sorts.empty?
    result = @q.result

    respond_to do |format|
      format.html do
        @pagy, @borrowers = pagy(
          result.includes(:barcode, :loans),
          items: params[:limit] || Pagy::VARS[:items]
        )
      end
      format.csv do
        @borrowers = result.includes(:barcode)
        data = CSV.generate(headers: true) do |csv|
          csv << %w[barcode name code email allowance]
          @borrowers.each do |borrower|
            csv << [
              borrower.barcode.code,
              borrower.name,
              borrower.code,
              borrower.email,
              borrower.allowance || 'unlimited'
            ]
          end
        end
        send_data data, filename: 'borrowers.csv'
      end
    end
  end

  def show
    @borrower = find_borrower params[:id]
  end

  def barcode
    @borrower = find_borrower params[:id]
    send_data @borrower.barcode.png,
              type: 'image/png',
              disposition: 'inline'
  end

  def new
    @borrower = Borrower.new
    @borrower.allowance = 1
  end

  def edit
    @borrower = find_borrower params[:id]
  end

  def create
    @borrower = Borrower.new(borrower_params)
    @barcode = Barcode.new barcode_param.merge(owner: @borrower)
    @barcode.generate_code

    if @borrower.save && @barcode.save
      redirect_to @borrower
    else
      render 'new'
    end
  end

  def upload
    csv = CSV.new params[:file].tempfile, headers: true

    Borrower.transaction do
      csv.each.with_index do |line, lineno|
        hash = line.to_h.slice 'name', 'email', 'code', 'allowance'

        Borrower.perform_upload lineno + 1,
                                line['operation'],
                                line['barcode'],
                                hash
      end
    end

    redirect_to borrowers_path, notice: 'Upload successful!'
  rescue UploadHelper::UploadException => exc
    redirect_to borrowers_path, alert: exc.render
  end

  def update
    @borrower = find_borrower params[:id]
    @barcode = @borrower.barcode

    if @borrower.update(borrower_params) && @barcode.update(barcode_param)
      redirect_to @borrower
    else
      render 'edit'
    end
  end

  def destroy
    @borrower = find_borrower params[:id]
    @borrower.destroy
    redirect_to borrowers_path
  end

  private

  # @todo move into {Borrower} class?
  # :reek:UtilityFunction
  def find_borrower(search_code)
    Borrower.find_by! code: search_code.downcase
  end

  def borrower_params
    params.require(:borrower).permit(:name, :email, :code, :allowance)
  end

  def barcode_param
    code = params.require(:borrower).permit(:barcode)[:barcode]
    ActionController::Parameters.new(code: code).permit!
  end
end
