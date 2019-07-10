class DevicesController < ApplicationController
  before_action :authenticate_admin!

  def index
    page = params[:page]
    devices = Device.order(:name).page(page)

    limit_value = params[:limit] || devices.limit_value
    @devices = devices.per(limit_value)
  end

  def show
    @device = Device.find params[:id]
  end

  def new
    @device = Device.new
  end

  def edit
    @device = Device.find params[:id]
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
    @device = Device.find params[:id]

    if @device.update device_params
      redirect_to @device
    else
      render 'edit'
    end
  end

  def delete
    @device = Device.find params[:id]
    @device.delete
    redirect_to devices_path
  end

  private

  def device_params
    params.require(:device).permit(:name, :description)
  end
end
