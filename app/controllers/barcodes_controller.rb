# frozen_string_literal: true

class BarcodesController < ApplicationController
  def index
    if (code = params[:id])
      redirect_to Barcode.find_by! code: code
      return
    end

    redirect_to root_path
  end

  def show
    @barcode = Barcode.find_by! code: params[:id]

    redirect_to @barcode.owner
  end
end
