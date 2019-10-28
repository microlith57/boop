# frozen_string_literal: true

require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class Barcode < ApplicationRecord
  DEFAULT_BARCODE_LENGTH = if ENV['DEFAULT_BARCODE_LENGTH'].to_i.zero?
                             10
                           else
                             ENV['DEFAULT_BARCODE_LENGTH'].to_i
                           end

  # @!attribute owner
  #   @return [Device, Issuer] The owner of the barcode.
  #   FIXME: Validate uniqueness
  belongs_to :owner, polymorphic: true

  # @!attribute code
  #   @return [String] The barcode's string representation.
  validates :code, presence: true,
                   uniqueness: true

  # BUG: Doesn't run?
  before_save :generate_code

  # @return [String] the {#code} as raw PNG data
  def png
    code_obj = Barby::Code128.new(code)
    Barby::PngOutputter.new(code_obj).to_png
  end

  # @return [String] This barcode's string representation.
  def to_s
    code
  end

  # @return [true, false] Is the owner of this barcode an {Issuer}?
  def represents_issuer?
    owner.is_a? Issuer
  end

  # @return [true, false] Is the owner of this barcode a {Device}?
  def represents_device?
    owner.is_a? Device
  end

  # @return [Issuer, nil] The {#owner} of the barcode, but only if they are an
  #   {Issuer}.
  def issuer
    owner if represents_issuer?
  end

  # The {#owner} of the barcode, but only if they are a {Device}.
  #
  # @return [Device, nil] The device this barcode represents.
  def device
    owner if represents_device?
  end

  # @return [Issuer] The {#owner} of the barcode, but only if they are
  #   an {Issuer}
  # @raise [ActiveRecord::RecordNotFound] if the owner is not an device
  def issuer!
    return issuer if represents_issuer?

    raise ActiveRecord::RecordNotFound
  end

  # @return [Device] The {#owner} of the barcode, but only if they are
  #   a {Device}
  # @raise [ActiveRecord::RecordNotFound] if the owner is not an issuer
  def device!
    return device if represents_device?

    raise ActiveRecord::RecordNotFound
  end

  # Generate a {#code} for this barcode.
  #
  # REVIEW: Should this be done differently?
  def generate_code
    return if code.present?

    self.code = SecureRandom.base58(DEFAULT_BARCODE_LENGTH)
  end
end
