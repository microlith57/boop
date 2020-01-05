# frozen_string_literal: true

class SettingsController < ApplicationController
  def index
    @query = Admin.ransack(params[:q])

    @pagy, @admins = pagy(
      @query.result(distinct: true),
      items: params[:limit] || Pagy::VARS[:items]
    )
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)

    if @admin.save
      redirect_to edit_setting_url(@admin)
    else
      render 'new'
    end
  end

  def edit
    @admin = Admin.find params[:id]
  end

  def update
    @admin = Admin.find params[:id]

    if @admin.update admin_params
      redirect_to edit_setting_url(@admin)
      flash.now[:notice] = 'Updated successfully'
    else
      render 'new'
    end
  end

  def destroy
    @admin = Admin.find params[:id]
    @admin.delete
    redirect_to settings_path
  end

  private

  def admin_params
    params.require(:admin).permit(:email)
  end
end
