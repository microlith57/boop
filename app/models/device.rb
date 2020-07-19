# frozen_string_literal: true

class Device < ApplicationRecord
  # @!attribute loans
  #   @return [Array<Loan>]
  has_many :loans, dependent: :nullify

  # @!attribute issuers
  #   @return [Array<Issuer>]
  has_many :issuers, through: :loans

  # @!attribute name
  #   @return [String]
  validates :name,
            presence: true,
            uniqueness: { case_insensitive: true }

  has_rich_text :notes

  # @!attribute barcode
  #   @return [Barcode]
  #   @todo
  #     REVIEW: Should old barcodes be preserved?
  has_one :barcode, as: :owner, dependent: :destroy

  # @return [String] the URL-safe {#name} of this Device.
  def to_param
    name.parameterize
  end

  # @return [Loan] the newest active loan on the device.
  def current_loan
    loans_by_creation_desc.active.first
  end

  # Issues the device *to* an Issuer, without checking allowance.
  #
  # @param new_issuer [Issuer] the issuer that the device will belong to.
  # @return [nil]
  # @raise [ActiveRecord::RecordNotSaved] if the device already has an active
  #   Loan
  def issue(issuer)
    if loans.active.any?
      raise ActiveRecord::RecordNotSaved, 'Device is already issued'
    end

    issuers << issuer
  end

  # Return the device from its issuer.
  # This is accomplished by returning the newest active loan on the device,
  # allowing for expansion to a loan stack.
  # :reek:FeatureEnvy
  #
  # @return [nil]
  def return
    loan = loans_by_creation_desc.active.first
    loan.return
    loan.save!
  end

  # Is the device issued?
  #
  # @return [true, false]
  def issued?
    loans.active.any?
  end

  # Is the device overdue?
  #
  # @return [true, false]
  def overdue?
    loans.overdue.any?
  end

  def issued_at
    current_loan.created_at if current_loan.present?
  end

  # The number of days the device's most overdue loan is overdue.
  # If there are no overdue loans, returns 0.
  #
  # @return [Integer]
  def days_overdue
    return 0 unless overdue?

    loans_by_creation_asc.overdue.first.days_overdue
  end

  def self.perform_upload(line, operation, barcode, hash)
    if operation.blank?
      raise UploadHelper::UploadException.new line,
                                              'operation must be present'
    end

    op = operation.downcase.to_sym

    case op
    when :create
      device = Device.new hash
      barcode = Barcode.new code: barcode, owner: device
      barcode.generate_code

      device.save!
      barcode.save!
    when :edit
      if barcode.blank?
        raise UploadHelper::UploadException.new line, 'barcode must be present'
      end

      barcode = Barcode.find_by! code: barcode
      device = barcode.device!

      device.update! hash
    when :delete
      if barcode.blank?
        raise UploadHelper::UploadException.new line, 'barcode must be present'
      end

      barcode = Barcode.find_by! code: barcode
      device = barcode.device!

      device.delete
    else
      raise UploadHelper::UploadException.new line,
                                              "operation must be 'create', " \
                                              "'edit', or 'delete'"
    end
  rescue ActiveRecord::RecordNotFound,
         ActiveRecord::RecordInvalid,
         ActiveRecord::RecordNotSaved => exc
    raise UploadHelper::UploadException.new line, exc.message
  end

  private

  # All loans on this device, oldest to newest.
  #
  # @return [ActiveRecord::Relation]
  def loans_by_creation_asc
    loans.order created_at: :asc
  end

  # All loans on this device, newest to oldest.
  #
  # @return [ActiveRecord::Relation]
  def loans_by_creation_desc
    loans.order created_at: :desc
  end
end
