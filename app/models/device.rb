# frozen_string_literal: true

require 'digest'
require 'securerandom'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class Device < ApplicationRecord
  # @return [ActiveSupport::TimeWithZone] The time (with zone) that the Boop
  #   'day' rolls over -- for example, with a rollover of 4:30 pm, if an issuer
  #   takes out a device at 4:00 pm and it is now 5:00 pm *the same day*, it is
  #   deemed the next dayso the device is 1 day overdue.
  DEFAULT_ROLLOVER_TIME = Time.zone.parse(ENV['ROLLOVER_TIME'] || '4:30 pm')

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
  scope :overdue, lambda {
    where.not(issued_at: nil).where('issued_at < ?', overdue_rollover - 1.day)
  }

  # Scope for devices issued before a given time.
  scope :issued_before, lambda { |time|
    where.not(issued_at: nil).where('issued_at < ?', time)
  }

  def to_param
    name.parameterize
  end
  
  # Issues the device *to* an Issuer, without checking allowance.
  #
  # @param new_issuer [Issuer] the issuer that the device will belong to.
  # @return [nil]
  def issue(new_issuer)
    raise 'Device is already issued' if issuer

    self.issuer = new_issuer
    self.issued_at = Time.current
  end

  # Return the device from its issuer.
  # 
  # @return [nil]
  def return
    self.issuer = nil
    self.issued_at = nil
  end

  # Find the overdue rollover time for today (or any datetime).
  #
  # @param date [DateTime, Date] the date to change
  # @return [DateTime] the overdue rollover for that date
  def self.overdue_rollover(date = DateTime.current)
    today_date_hash = {
      year: date.year,
      month: date.month,
      day: date.day
    }
    DEFAULT_ROLLOVER_TIME.change(today_date_hash)
  end

  # Is the device issued?
  # 
  # @return [true, false]
  def issued?
    (issuer && issued_at)
  end

  # Is the device overdue?
  # 
  # @return [true, false]
  def overdue?
    return false unless issued?

    issued_at < Device.overdue_rollover
  end

  # Was the device issued before a given time?
  # 
  # @param time [DateTime] the time to check
  # @return [true, false]
  def issued_before?(time)
    return false unless issued?

    issued_at < time
  end

  # The number of days the device is overdue.
  # 
  # @return [Integer]
  def days_overdue
    return 0 unless overdue?

    date_today  = Internal.adjust_by_rollover DateTime.current
    date_issued = Internal.adjust_by_rollover issued_at

    (date_today - date_issued).to_i
  end

  # Convert the barcode to a PNG.
  #
  # @return [String] the raw PNG data
  def barcode_png
    barcode = Barby::Code128.new(self.barcode)
    Barby::PngOutputter.new(barcode).to_png
  end

  private

  # Generate a barcode for an issuer.
  # 
  # @return [String] the string representation of the barcode.
  # 
  # TODO: Generate valid barcodes
  # TODO: Refactor
  # :reek:NilCheck
  def generate_barcode
    return unless barcode.nil? || salt.nil?

    self.salt = SecureRandom.base64(20)
    hash = Digest::SHA256.hexdigest name + salt
    self.barcode = hash[0...10]
  end

  module Internal
    # Convert a datetime into a date, but the 'rollover' between one day and the
    # next is, instead of midnight, an arbitrary other time
    # (from {Device.overdue_rollover}).
    # 
    # @param time [DateTime] the time to be converted.
    # @return [Date] the date obtained.
    # 
    # TODO: Refactor
    # :reek:DuplicateMethodCall
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
