# frozen_string_literal: true

require 'csv'

class IssuersController < ApplicationController
  before_action :authenticate_admin!

  def index
    query = params[:q]

    if query && (
      bar = Barcode.find_by code: query[:name_or_code_or_email_cont]
    ) && bar.issuer?
      redirect_to bar.issuer
      return
    end

    @q = Issuer.ransack query
    @q.sorts = 'name asc' if @q.sorts.empty?

    @pagy, @issuers = pagy(
      @q.result(distinct: true),
      items: params[:limit] || Pagy::VARS[:items]
    )

    respond_to do |format|
      format.html
      format.csv do
        data = CSV.generate(headers: true) do |csv|
          csv << %w[barcode name code email allowance]
          @issuers.each do |issuer|
            csv << [
              issuer.barcode.code,
              issuer.name,
              issuer.code,
              issuer.email,
              issuer.allowance || 'unlimited'
            ]
          end
        end
        send_data data, filename: 'issuers.csv'
      end
    end
  end

  def show
    @issuer = find_issuer params[:id]
  end

  def barcode
    @issuer = find_issuer params[:id]
    send_data @issuer.barcode.png,
              type: 'image/png',
              disposition: 'inline'
  end

  def new
    @issuer = Issuer.new
    @issuer.allowance = 1
  end

  def edit
    @issuer = find_issuer params[:id]
  end

  def create
    @issuer = Issuer.new(issuer_params)
    @barcode = Barcode.new barcode_param.merge(owner: @issuer)
    @barcode.generate_code

    if @issuer.save && @barcode.save
      redirect_to @issuer
    else
      render 'new'
    end
  end

  def upload
    csv = CSV.new params[:file].tempfile, headers: true

    Issuer.transaction do
      csv.each.with_index do |line, lineno|
        hash = line.to_h.slice 'name', 'email', 'code', 'allowance'

        Issuer.perform_upload lineno + 1,
                              line['operation'],
                              line['barcode'],
                              hash
      end
    end

    redirect_to issuers_path, notice: 'Upload successful!'
  rescue UploadHelper::UploadException => exc
    redirect_to issuers_path, alert: exc.render
  end

  def update
    @issuer = find_issuer params[:id]
    @barcode = @issuer.barcode

    if @issuer.update(issuer_params) && @barcode.update(barcode_param)
      redirect_to @issuer
    else
      render 'edit'
    end
  end

  def destroy
    @issuer = find_issuer params[:id]
    @issuer.delete
    redirect_to issuers_path
  end

  private

  # @todo move into {Issuer} class?
  # :reek:UtilityFunction
  def find_issuer(search_code)
    Issuer.find_by! code: search_code.downcase
  end

  def issuer_params
    params.require(:issuer).permit(:name, :email, :code, :allowance)
  end

  def barcode_param
    code = params.require(:issuer).permit(:barcode)[:barcode]
    ActionController::Parameters.new(code: code).permit!
  end
end
