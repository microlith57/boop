# frozen_string_literal: true

FactoryBot.define do
  factory :barcode do
    # for_device

    # trait :for_borrower do
    #   association :owner, factory: :borrower
    # end

    # trait :for_device do
    #   association :owner, factory: :device
    # end

    add_attribute :code do
      Barcode.generate_code
    end
  end

  factory :borrower do
    name  { 'John Smith' }
    code  { Borrower::Internal.generate_code name }
    email { "#{code}@example.org" }
    association :barcode

    factory :borrower_with_loans do
      transient do
        loans_count { 5 }
      end

      after(:create) do |borrower, evaluator|
        create_list :loan, evaluator.loans_count,
                    borrower: borrower, returned_at: 24.hours.ago
      end

      factory :active_borrower do
        after(:create) do |borrower|
          borrower.loans << build(:loan, borrower: borrower)
        end
      end
    end
  end

  factory :loan do
    device
    borrower
    returned_at { nil }
  end

  factory :device do
    name { 'CB-Y-01' }
    association :barcode

    factory :issued_device do
      # before(:create) do |_device|
      #   @instance.save!
      #   @instance.barcode.save!
      # end

      after(:create) do |device|
        # @instance.loans << build(:loan, device: @instance)
        create_list :loan, 1,
                    device: device
      end
    end
  end
end
