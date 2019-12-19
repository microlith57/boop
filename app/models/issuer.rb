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

  # @todo custom validation classes
  # @!attribute code
  #   @return [String]
  validates :code,
            presence: true,
            uniqueness: { case_insensitive: true },
            format: { with: /\A[a-z0-9]+\z/ } # Alphanumeric

  # @todo custom validation classes
  # @!attribute email
  #   @return [String]
  validates :email,
            presence: true,
            format: { with: /\A[^@\s]+@[^@\s]+\z/ } # Has an '@'

  # @!attribute allowance
  #   @return [Integer, nil]
  validates :allowance,
            numericality: { only_integer: true, allow_nil: true }

  # @!attribute barcode
  #   @return [Barcode] The issuer's barcode
  #   @todo
  #     REVIEW: Should old barcodes be preserved?
  has_one :barcode, as: :owner, dependent: :destroy

  # @return [Array(Device)] this issuer's overdue devices.
  def overdues
    devices.overdue
  end

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
      overdues.count,
      devices.count,
      allowance || infinity_sign
    ].join('/')
  end

  # @return [true, false] Is the issuer allowed another device?
  # :reek:NilCheck
  def allowed_another_device?
    return true if allowance.blank?

    devices.count < allowance
  end

  # @return ['exceeded', 'reached', 'not reached'] Human friendly allowance state.
  #   Used like 'This issuer has already *exceeded* their allowance'.
  # :reek:NilCheck
  def allowance_state
    return 'not met' if allowance.blank?

    case devices.count <=> allowance
    when 1
      'exceeded'
    when 0
      'reached'
    when -1
      'not reached'
    end
  end

  module Internal
    # @param name [String] The issuer's full name
    # @return [String] A 3-letter issuer code for the issuer
    def self.generate_code(name)
      parts = name.downcase.split
      first = parts.first
      last = parts.last
      return '' if parts.empty?
      return first[0..3] if parts.length == 1

      first[0] + last[0..1]
    end
  end
end
