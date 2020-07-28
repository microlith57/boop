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
  #   @todo
  #     FIXME: Validate uniqueness
  belongs_to :owner, polymorphic: true

  # @!attribute code
  #   @return [String] The barcode's string representation.
  validates :code, presence: true,
                   uniqueness: true

  def to_param
    code
  end

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
  # @raise [ActiveRecord::RecordNotFound] if the owner is not an issuer
  def issuer!
    return issuer if represents_issuer?

    raise ActiveRecord::RecordNotFound, 'Barcode not for an issuer'
  end

  # @return [Device] The {#owner} of the barcode, but only if they are
  #   a {Device}
  # @raise [ActiveRecord::RecordNotFound] if the owner is not a device
  def device!
    return device if represents_device?

    raise ActiveRecord::RecordNotFound, 'Barcode not for a device'
  end

  # Generate a {#code} for this barcode, if one does not already exist.
  #
  # @todo
  #   REVIEW: Should this be done differently?
  def generate_code
    return if code.present?

    generate_code!
  end

  # Generate a {#code} for this barcode.
  def generate_code!
    self.code = Barcode.generate_code
  end

  # @param length [Integer] The length of code to generate
  # @return [String] A base 58 code of given length
  def self.generate_code(length = DEFAULT_BARCODE_LENGTH)
    SecureRandom.base58(length)
  end
end
