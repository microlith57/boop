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
      expect(device).not_to be_issued
      expect(device).not_to be_overdue
      expect(device.days_overdue).to eq 0
    end

    it 'correctly chooses the most-overdue loan' do
      borrower = build(:borrower)
      borrower.save!
      borrower.barcode.save!

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
                     device: device, borrower: borrower,
                     created_at: time
        loan.save!

        device.loans << loan
      end

      expect(device.days_overdue).to eq correct_num_days
    end
  end

  it 'can be issued' do
    borrower = build :borrower
    borrower.save!
    device = build :device

    device.issue borrower
    device.save!
    expect(device.current_loan.borrower).to eq borrower
    expect(borrower.devices).to include device
  end

  it 'can be returned' do
    device = build :device
    device.save!
    borrower = build :borrower
    borrower.save!
    device.issue borrower
    expect(device).to be_issued

    device.return
    device.save!
    expect(device).not_to be_issued
  end

  it 'has a barcode' do
    device = build :device
    device.save!

    expect(device.barcode).to be_present
  end
end
