# frozen_string_literal: true

class IssuersController < ApplicationController
  before_action :authenticate_admin!

  def index
    page = params[:page]
    issuers = Issuer.order(sort_type => sort_direction).page(page)

    limit_value = params[:limit] || issuers.limit_value
    @issuers = issuers.per(limit_value)
  end

  def show
    @issuer = find_issuer params[:id]
  end

  def barcode
    @issuer = find_issuer params[:id]
    send_data @issuer.barcode_png,
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

    if @issuer.save
      redirect_to @issuer
    else
      render 'new'
    end
  end

  def update
    @issuer = find_issuer params[:id]

    if @issuer.update issuer_params
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

  def find_issuer(search_code)
    issuer = Issuer.find_by code: search_code.downcase
    raise ActiveRecord::RecordNotFound if issuer.nil?

    issuer
  end

  def issuer_params
    params.require(:issuer).permit(:name, :email, :code, :allowance, :barcode)
  end

  def sort_type
    type = (params[:sort] || 'name').strip
    type = 'name' unless type.in? %w[name email code description barcode allowance created_at]

    type.to_sym
  end

  def sort_direction
    dir = (params[:sort_dir] || 'asc').strip
    dir = 'asc' unless dir.in? %w[asc desc]

    dir.to_sym
  end
end
