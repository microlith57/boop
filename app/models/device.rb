# frozen_string_literal: true

require 'digest'
require 'securerandom'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class Device < ApplicationRecord
  DEFAULT_ROLLOVER_TIME = Time.parse(ENV['ROLLOVER_TIME'] || '4:30 pm')

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

  # Scope for overdue devices.
  scope :overdue, -> { where.not(issued_at: nil).where('issued_at < ?', overdue_rollover - 1.day) }

  # Scope for devices issued before a given time.
  scope :issued_before, ->(time) { where.not(issued_at: nil).where('issued_at < ?', time) }  

  def to_param
    name.parameterize
  end

  # Issues the device *to* an Issuer.
  # Returns an Array of errors (can be empty).
  # TODO: Use exceptions instead of these silly Arrays
  def issue(to: nil, override_allowance: false)
    errors = []

    raise 'cannot issue without an issuer' if to.nil?

    if issuer
      errors << 'device is already issued'
      return errors
    end

    if !override_allowance && to.allowance && to.devices.length + 1 > to.allowance
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

  # Find the overdue rollover time for today.
  def self.overdue_rollover(date = DateTime.current)
    today_date_hash = {
      year:  date.year,
      month: date.month,
      day:   date.day,
    }
    DEFAULT_ROLLOVER_TIME.change(today_date_hash)
  end

  def overdue?
    return false if issued_at.nil?

    issued_at < Device.overdue_rollover
  end

  def issued_before?(time)
    return false if issued_at.nil?

    issued_at < time
  end

  def days_overdue
    return 0 if !overdue?
    date_today  = Internal.adjust_by_rollover DateTime.current
    date_issued = Internal.adjust_by_rollover issued_at

    (date_today - date_issued).to_i
  end

  def barcode_png
    barcode = Barby::Code128.new(self.barcode)
    Barby::PngOutputter.new(barcode).to_png
  end

  private

  # TODO: Generate valid barcodes
  def generate_barcode
    return unless barcode.nil? || salt.nil?

    self.salt = SecureRandom.base64(20)
    hash = Digest::SHA256.hexdigest name + salt
    self.barcode = hash[0...10]
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
