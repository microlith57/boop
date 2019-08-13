# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_admin!

  def index
    page = params[:page]
    @q = Device.ransack(params[:q])
    devices = @q.result(distinct: true).page(page)

    limit_value = params[:limit] || devices.limit_value
    @devices = devices.per(limit_value)
  end

  def show
    @device = find_device params[:id]
  end

  def barcode
    @device = find_device params[:id]
    send_data @device.barcode_png,
              type: 'image/png',
              disposition: 'inline'
  end

  def new
    @device = Device.new
  end

  def edit
    @device = find_device params[:id]
  end

  def create
    @device = Device.new(device_params)

    if @device.save
      redirect_to @device
    else
      render 'new'
    end
  end

  def update
    @device = find_device params[:id]

    if @device.update device_params
      redirect_to @device
    else
      render 'edit'
    end
  end

  def destroy
    @device = find_device params[:id]
    @device.delete
    redirect_to devices_path
  end

  private

  def find_device(search_name)
    table = Device.arel_table
    devices = Device.where(table[:name].matches(search_name))
    raise ActiveRecord::RecordNotFound if devices.blank?

    devices.first
  end

  def device_params
    params.require(:device).permit(:name, :description, :barcode)
  end
end
