# frozen_string_literal: true

class Loan < ApplicationRecord
  # @return [ActiveSupport::TimeWithZone] The time (with zone) that the Boop
  #   'day' rolls over -- for example, with a rollover of 4:30 pm, if an issuer
  #   takes out a device at 4:00 pm and it is now 5:00 pm *the same day*, it is
  #   deemed the next dayso the device is 1 day overdue.
  DEFAULT_ROLLOVER_TIME = Time.zone.parse(ENV['ROLLOVER_TIME'] || '4:30 pm NZST')

  # @!attribute issuer
  #   @return [Issuer]
  belongs_to :issuer

  # @!attribute device
  #   @return [Device]
  belongs_to :device

  # @!parse
  #   # Scope for active loans
  #   #
  #   # @return [ActiveRecord::Relation]
  #   def self.overdue; end
  scope :active, lambda {
    where returned_at: nil
  }

  # @!parse
  #   # Scope for returned loans
  #   #
  #   # @return [ActiveRecord::Relation]
  #   def self.overdue; end
  scope :returned, lambda {
    where.not returned_at: nil
  }

  # @!parse
  #   # Scope for overdue devices
  #   #
  #   # @return [ActiveRecord::Relation]
  #   def self.overdue; end
  scope :overdue, lambda {
    active.where 'created_at < ?', Loan.overdue_rollover - 1.day
  }

  # Is the loan active?
  #
  # @return [true, false]
  def active?
    returned_at.blank?
  end

  # Has the loan been returned?
  #
  # @return [true, false]
  def returned?
    returned_at.present?
  end

  # Is the loan overdue?
  #
  # @return [true, false]
  def overdue?
    return false if returned?

    created_at.before? Loan.overdue_rollover(1.day.ago)
  end

  def return
    self.returned_at = DateTime.current
  end

  # The number of days the loan is overdue.
  #
  # @return [Integer]
  def days_overdue
    return 0 unless overdue?

    date_today  = Loan.adjust_by_rollover DateTime.current
    date_issued = Loan.adjust_by_rollover created_at

    (date_today - date_issued).to_i
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

  # Convert a datetime into a date, but the 'rollover' between one day and the
  # next is, instead of midnight, an arbitrary other time
  # (from {Loan.overdue_rollover}).
  #
  # @param time [DateTime] the time to be converted.
  # @return [Date] the date obtained.
  def self.adjust_by_rollover(time)
    rollover = Loan.overdue_rollover time
    date = time.to_date

    if time < rollover
      date
    else
      date + 1.day
    end
  end
end
