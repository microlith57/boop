# frozen_string_literal: true

FactoryBot.define do
  factory :barcode do
    # for_device

    # trait :for_issuer do
    #   association :owner, factory: :issuer
    # end

    # trait :for_device do
    #   association :owner, factory: :device
    # end

    add_attribute :code do
      Barcode.generate_code
    end
  end

  factory :issuer do
    name  { 'John Smith' }
    code  { Issuer::Internal.generate_code name }
    email { "#{code}@example.org" }
    association :barcode

    factory :issuer_with_loans do
      transient do
        loans_count { 5 }
      end

      after(:create) do |issuer, evaluator|
        create_list :loan, evaluator.loans_count,
                    issuer: issuer, returned_at: 24.hours.ago
      end

      factory :active_issuer do
        after(:create) do |issuer|
          issuer.loans << build(:loan, issuer: issuer)
        end
      end
    end
  end

  factory :loan do
    device
    issuer
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
