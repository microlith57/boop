# frozen_string_literal: true

FactoryBot.define do
  factory :barcode do
    sequence :code do
      Barcode.generate_code
    end
  end

  factory :device do
    name   { 'CB-Y-01' }
    issuer { nil }
    association :barcode # , strategy: :build

    # after(:create) do |device|
    #   bar = device.barcode
    #   bar.generate_code!
    #   bar.save!
    # end

    factory :issued_device do
      issuer
      issued_at { 5.minutes.ago }
    end
  end

  factory :issuer do
    name  { 'John Smith' }
    code  { 'jsm' }
    email { "#{code}@example.org" }
    association :barcode # , strategy: :build

    # after(:create) do |issuer|
    #   bar = issuer.barcode
    #   bar.generate_code!
    #   bar.save!
    # end
  end
end
