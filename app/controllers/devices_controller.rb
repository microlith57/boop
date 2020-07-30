# frozen_string_literal: true

require 'csv'

class DevicesController < ApplicationController
  before_action :authenticate_admin!

  def index
    query = params[:q]

    if query && (bar = Barcode.find_by code: query[:name_cont]) && bar.device?
      redirect_to bar.device
      return
    end

    @q = Device.ransack query
    @q.sorts = 'name asc' if @q.sorts.empty?

    @pagy, @devices = pagy(
      @q.result(distinct: true),
      items: params[:limit] || Pagy::VARS[:items]
    )

    respond_to do |format|
      format.html
      format.csv do
        data = CSV.generate(headers: true) do |csv|
          csv << %w[barcode name]
          @devices.each do |device|
            csv << [
              device.barcode.code,
              device.name
            ]
          end
        end
        send_data data, filename: 'devices.csv'
      end
    end
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

  def upload
    csv = CSV.new params[:file].tempfile, headers: true

    Device.transaction do
      csv.each.with_index do |line, lineno|
        hash = line.to_h.slice 'name', 'description', 'notes'

        Device.perform_upload lineno + 1,
                              line['operation'],
                              line['barcode'],
                              hash
      end
    end

    redirect_to devices_path, notice: 'Upload successful!'
  rescue UploadHelper::UploadException => exc
    redirect_to devices_path, alert: exc.render
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
    params.require(:device).permit(:name, :description, :notes)
  end

  def barcode_param
    code = params.require(:device).permit(:barcode)[:barcode]
    ActionController::Parameters.new(code: code).permit!
  end
end
