# frozen_string_literal: true

FactoryBot.define do
  factory :barcode do
    add_attribute :code do
      Barcode.generate_code
    end
  end

  factory :device do
    name   { 'CB-Y-01' }
    issuer { nil }
    association :barcode

    factory :issued_device do
      issuer
      issued_at { 5.minutes.ago }
    end
  end

  factory :issuer do
    name  { 'John Smith' }
    code  { Issuer::Internal.generate_code name }
    email { "#{code}@example.org" }
    association :barcode
  end
end
