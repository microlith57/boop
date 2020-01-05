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

  # BUG: Loading without turbolinks works; loading with turbolinks (eg. from
  # other page) replaces the body with raw PNG data and ruins the display
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

  # TODO: Refactor
  def upload
    params[:files].each do |file|
      csv = CSV.new file.tempfile, headers: true
      Device.transaction do
        csv.each do |line|
          code = line['barcode']
          line_params = ActionController::Parameters.new(line.to_hash).permit(:name)

          if code.present? && (barcode = Barcode.find_by code: code)
            device = barcode.device!
            device.update! line_params
          else
            device = Device.new(line_params)
            barcode = Barcode.new code: code, owner: device
            barcode.generate_code
            device.save!
            barcode.save!
          end
        end
      end
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
    params.require(:device).permit(:name, :description, :notes)
  end

  def barcode_param
    code = params.require(:device).permit(:barcode)[:barcode]
    ActionController::Parameters.new(code: code).permit!
  end
end
