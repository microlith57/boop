# frozen_string_literal: true

# Represents a person who can issue devices.
class Borrower < ApplicationRecord
  # @!attribute loans
  #   @return [Array<Loan>]
  has_many :loans, dependent: :destroy

  # @!attribute devices
  #   @return [Array<Device>]
  has_many :devices, through: :loans

  # @!attribute name
  #   @return [String]
  validates :name,
            presence: true

  has_rich_text :notes

  # @todo custom validation classes
  # @!attribute code
  #   @return [String]
  validates :code,
            presence: true,
            uniqueness: { case_insensitive: true },
            format: { with: /\A[a-z0-9\-_]+\z/ } # Alphanumeric

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
  #   @return [Barcode] The borrower's barcode
  #   @todo
  #     REVIEW: Should old barcodes be preserved?
  has_one :barcode, as: :owner, dependent: :destroy

  # @return [Array(Loan)] this borrower's overdue loans.
  def overdues
    loans.active.overdue
  end

  # @return [String] the URL-safe {#code} of this Borrower.
  def to_param
    code.parameterize
  end

  # Generates a string formatted like `overdues/loans/allowance`, where
  # 'overdues' is the number of overdue devices, 'loans' is the total loans,
  # and 'allowance' is the borrower's allowance (or infinity).
  #
  # @param infinity_sign [String] The infinity sign to use for borrowers without
  #   allowances. Defaults to U+221E INFINITY.
  # @return [String] The summary string.
  def device_summary(infinity_sign: '∞')
    [
      overdues.size,
      loans.active.size,
      allowance || infinity_sign
    ].join('/')
  end

  # @return [true, false] Is the borrower allowed another device?
  # :reek:NilCheck
  def allowed_another_device?
    return true if allowance.blank?

    loans.active.size < allowance
  end

  # @return ['exceeded', 'reached', 'not reached'] Human friendly allowance
  #   state.
  #   Used like 'This borrower has *exceeded* their allowance'.
  # :reek:NilCheck
  def allowance_state
    return 'not met' if allowance.blank?

    case loans.active.size <=> allowance
    when 1
      'exceeded'
    when 0
      'reached'
    when -1
      'not reached'
    end
  end

  def self.perform_upload(line, operation, barcode, hash)
    if operation.blank?
      raise UploadHelper::UploadException.new line,
                                              'operation column must be present'
    end

    op = operation.downcase.to_sym

    case op
    when :create
      borrower = Borrower.new hash
      barcode = Barcode.new code: barcode, owner: borrower
      barcode.generate_code

      borrower.save!
      barcode.save!
    when :edit
      raise UploadHelper::UploadException.new line, 'barcode must be present' if barcode.blank?

      barcode = Barcode.find_by! code: barcode
      borrower = barcode.borrower!

      borrower.update! hash
    when :delete
      raise UploadHelper::UploadException.new line, 'barcode must be present' if barcode.blank?

      barcode = Barcode.find_by! code: barcode
      borrower = barcode.borrower!

      borrower.destroy!
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

  module Internal
    # @param name [String] The borrower's full name
    # @return [String] A 3-letter borrower code for the borrower
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
