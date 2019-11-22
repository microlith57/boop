# frozen_string_literal: true

class IssuersController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_admin!

  def index
    @query = Issuer.ransack(params[:q])

    @pagy, @issuers = pagy(
      @query.result(distinct: true),
      items: params[:limit] || Pagy::VARS[:items]
    )
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
