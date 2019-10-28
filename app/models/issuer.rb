# frozen_string_literal: true

# Represents a person who can issue devices.
class Issuer < ApplicationRecord
  # @!attribute devices
  #   @return [Array<Device>]
  has_many :devices, dependent: :nullify

  # @!attribute name
  #   @return [String]
  validates :name,
            presence: true

  # TODO: Custom validation classes
  # @!attribute code
  #   @return [String]
  validates :code,
            presence: true,
            uniqueness: { case_insensitive: true },
            format: { with: /\A[a-z0-9]+\z/ } # Alphanumeric

  # TODO: Custom validation classes
  # @!attribute email
  #   @return [String]
  validates :email,
            presence: true,
            format: { with: /\A[^@\s]+@[^@\s]+\z/ } # Has an '@'

  # @!attribute allowance
  #   @return [Integer, nil]
  validates :allowance,
            numericality: { only_integer: true, allow_nil: true }

  # REVIEW: Should old barcodes be preserved?
  # @!attribute barcode
  #   @return [Barcode] The issuer's barcode
  has_one :barcode, as: :owner, dependent: :destroy

  # @return [String] the URL-safe {#code} of this Issuer.
  def to_param
    code.parameterize
  end

  # Generates a string formatted like `overdues/issues/allowance`, where
  # 'overdues' is the number of overdue devices, 'issues' is the total issued
  # devices, and 'allowance' is the issuer's allowance (or infinity).
  #
  # @param infinity_sign [String] The infinity sign to use for issuers without
  #   allowances. Defaults to U+221E.
  # @return [String] The summary string.
  def device_summary(infinity_sign: '∞')
    [
      devices.overdue.length,
      devices.length,
      allowance || infinity_sign
    ].join('/')
  end
end
