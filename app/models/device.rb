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

  # Issues the device *to* an Issuer.
  # Returns an Array of errors (can be empty).
  # TODO: Use exceptions instead of these silly Arrays
  def issue(to: nil)
    errors = []

    raise 'cannot issue without an issuer' if to.nil?

    if issuer
      errors << 'device is already issued'
      return errors
    end

    if to.allowance && to.devices.length + 1 > to.allowance
      errors << 'allowance must not be exceeded'
      return errors
    end

    self.issuer = to
    self.issued_at = Time.current

    []
  end

  # Return the device from its issuer.
  # Returns an Array of errors (always empty; this method never fails)
  # TODO: Use exceptions instead of these silly Arrays
  def return
    self.issuer = nil
    self.issued_at = nil

    []
  end

  # TODO: Add timezone to config?
  # TODO: Configurable rollover time
  def self.overdue_rollover(time = DateTime.current)
    # Time.parse('4:30 pm NZST').utc - 1.day
    time.at_noon.advance(hours: 4, minutes: 30)
  end

  # Scope for overdue devices.
  def self.overdue
    where.not(issued_at: nil).where('issued_at < ?', overdue_rollover - 1.day)
  end

  def self.issued_before(time)
    where.not(issued_at: nil).where('issued_at < ?', time)
  end

  def overdue?
    return false if issued_at.nil?

    issued_at < (overdue_rollover - 1.day)
  end

  def issued_before?(time)
    return false if issued_at.nil?

    issued_at < time
  end

  def days_overdue
    date_today  = Internal.adjust_by_rollover DateTime.current
    date_issued = Internal.adjust_by_rollover issued_at

    (date_today - date_issued).to_i
  end

  private

  # TODO: Generate valid barcodes
  def generate_barcode
    return unless barcode.nil? || salt.nil?

    self.salt = SecureRandom.base64(20)
    self.barcode = Digest::SHA256.hexdigest name + salt
  end

  module Internal
    def self.adjust_by_rollover(time)
      rollover = Device.overdue_rollover time
      if time < rollover
        time.to_date
      else
        time.to_date + 1.day
      end
    end
  end
end
