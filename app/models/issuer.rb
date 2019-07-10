# frozen_string_literal: true

require 'digest'
require 'securerandom'

# Represents a person who can issue devices.
class Issuer < ApplicationRecord
  has_many :devices, dependent: :nullify

  validates :name,
            presence: true

  validates :email,
            presence: true,
            format: { with: /\A[^@\s]+@[^@\s]+\z/ } # Has an '@'

  validates :allowance,
            numericality: { only_integer: true, allow_nil: true }

  validates :barcode,
            presence: true

  validates :salt,
            presence: true

  before_validation :generate_barcode

  private

  # TODO: Generate valid barcodes
  def generate_barcode
    return unless barcode.nil? || salt.nil?

    self.salt = SecureRandom.base64(20)
    self.barcode = Digest::SHA256.hexdigest name + salt
  end
end
