# frozen_string_literal: true

require 'csv'

class DevicesController < ApplicationController
  before_action :authenticate_admin!

  def index
    query = params[:q]

    if query && (bar = Barcode.find_by code: query[:name_or_code_cont]) && bar.device?
      redirect_to bar.device
      return
    end

    @q = Device.ransack query
    @q.sorts = 'name asc' if @q.sorts.empty?
    result = @q.result

    respond_to do |format|
      format.html do
        @pagy, @devices = pagy(
          result.includes(:barcode, :loans),
          items: params[:limit] || Pagy::VARS[:items]
        )
      end
      format.csv do
        @devices = result.includes(:barcode)

        data = CSV.generate(headers: true) do |csv|
          csv << %w[barcode name code]
          @devices.each do |device|
            csv << [
              device.barcode.code,
              device.name,
              device.code
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
        hash = line.to_h.slice 'name', 'code', 'description', 'notes'

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
    @device.destroy
    redirect_to devices_path
  end

  private

  # @todo move into {Device} class?
  # :reek:UtilityFunction
  def find_device(search_code)
    Device.find_by! code: search_code.downcase
  end

  def device_params
    params.require(:device).permit(:name, :code, :description, :notes)
  end

  def barcode_param
    code = params.require(:device).permit(:barcode)[:barcode]
    ActionController::Parameters.new(code: code).permit!
  end
end
