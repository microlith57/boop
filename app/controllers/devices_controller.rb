# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_admin!

  def index
    page = params[:page]
    @query = Device.ransack(params[:q])
    devices = @query.result(distinct: true).page(page)

    limit_value = params[:limit] || devices.limit_value
    @devices = devices.per(limit_value)
  end

  def show
    @device = find_device params[:id]
  end

  def barcode
    @device = find_device params[:id]
    send_data @device.barcode.png,
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
    @barcode = Barcode.new barcode_param.merge(owner: @device)
    @barcode.generate_code

    if @device.save && @barcode.save
      redirect_to @device
    else
      render 'new'
    end
  end

  def update
    @device = find_device params[:id]
    @barcode = @device.barcode

    if @device.update(device_params) && @barcode.update(barcode_param)
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

  # @todo move into {Device} class?
  # :reek:UtilityFunction
  def find_device(search_name)
    table = Device.arel_table
    Device.find_by!(table[:name].matches(search_name))
  end

  def device_params
    params.require(:device).permit(:name, :description)
  end

  def barcode_param
    code = params.require(:device).permit(:barcode)[:barcode]
    ActionController::Parameters.new(code: code).permit!
  end
end
