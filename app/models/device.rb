# frozen_string_literal: true

require 'digest'
require 'securerandom'

class Device < ApplicationRecord
  belongs_to :issuer,
             optional: true

  validates :name,
            presence: true,
            uniqueness: { case_insensitive: true }

  validates :barcode,
            presence: true

  validates :salt,
            presence: true

  before_validation :generate_barcode

  def to_param
    name.parameterize
  end

  private

  # TODO: Generate valid barcodes
  def generate_barcode
    return unless barcode.nil? || salt.nil?

    self.salt = SecureRandom.base64(20)
    self.barcode = Digest::SHA256.hexdigest name + salt
  end
end
