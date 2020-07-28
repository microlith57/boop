# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Device do
  context 'overdue logic' do
    around do |example|
      Timecop.freeze DateTime.parse('3:00 pm NZST')
      example.run
      Timecop.return
    end

    it 'can detect non-issued devices' do
      device = build :device
      expect(device.issued?).to be_falsy
      expect(device.overdue?).to be_falsy
      expect(device.days_overdue).to eq 0
    end

    it 'correctly chooses the most-overdue loan' do
      issuer = build(:issuer)
      issuer.save!
      issuer.barcode.save!

      times = [
        5.minutes.ago,
        p_time('9:20 am NZST'),
        p_time('3:15 pm NZST') - 1.day,
        p_time('4:45 pm NZST') - 3.days,
        p_time('4:45 pm NZST') - 3.days,
        p_time('8:56 am NZST') - 5.days # 5 days overdue
      ]
      correct_num_days = 5

      device = build :device
      device.save!

      times.each do |time|
        loan = build :loan,
                     device: device, issuer: issuer,
                     created_at: time
        loan.save!

        device.loans << loan
      end

      expect(device.days_overdue).to eq correct_num_days
    end
  end

  it 'can be issued' do
    issuer = build :issuer
    issuer.save!
    device = build :device

    device.issue issuer
    device.save!
    expect(device.current_loan.issuer).to eq issuer
    expect(issuer.devices).to include device
  end

  it 'can be returned' do
    device = build :device
    device.save!
    issuer = build :issuer
    issuer.save!
    device.issue issuer
    expect(device.issued?).to be_truthy

    device.return
    device.save!
    expect(device.issued?).to be_falsy
  end

  it 'has a barcode' do
    device = build :device
    device.save!

    expect(device.barcode).to be_present
  end
end
