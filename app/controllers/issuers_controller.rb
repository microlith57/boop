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
    @issuer = Issuer.find params[:id]
  end

  def new
    @issuer = Issuer.new
  end

  def edit
    @issuer = Issuer.find params[:id]
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
    @issuer = Issuer.find params[:id]

    if @issuer.update issuer_params
      redirect_to @issuer
    else
      render 'edit'
    end
  end

  def delete
    @issuer = Issuer.find params[:id]
    @issuer.delete
    redirect_to issuers_path
  end

  private

  def issuer_params
    params.require(:issuer).permit(:name, :email)
  end
end
