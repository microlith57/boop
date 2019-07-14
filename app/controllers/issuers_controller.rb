# frozen_string_literal: true

class IssuersController < ApplicationController
  before_action :authenticate_admin!

  def index
    page = params[:page]
    issuers = Issuer.order(:name).page(page)

    limit_value = params[:limit] || issuers.limit_value
    @issuers = issuers.per(limit_value)
  end

  def show
    @issuer = find_issuer params[:id]
  end

  def new
    @issuer = Issuer.new
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

  def delete
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
    params.require(:issuer).permit(:name, :email, :code)
  end
end
