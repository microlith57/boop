# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Loan, type: :model do
  context 'overdue logic' do
    around do |example|
      Timecop.freeze DateTime.parse('3:00 pm NZST')
      example.run
      Timecop.return
    end

    it 'can determine overdue loans' do
      [
        p_time('4:25 pm NZST') - 1.day,
        p_time('3:15 pm NZST') - 1.day,
        p_time('8:56 am NZST') - 1.day,
        3.days.ago,
        p_time('4:45 pm NZST') - 2.days
      ].each do |time|
        loan = build :loan, created_at: time

        expect(loan).to be_active
        expect(loan.overdue?)
          .to be_truthy,
              "loan created at #{loan.created_at.to_s(:short)} " \
              "wasn't detected as overdue at #{DateTime.current.to_s(:short)}"
        expect(loan.days_overdue).to be >= 1
      end
    end

    it 'can determine non-overdue loans' do
      [
        p_time('2:00 pm NZST'),
        p_time('9:20 am NZST'),
        p_time('12:00 pm NZST'),
        p_time('4:45 pm NZST') - 1.day,
        5.minutes.ago
      ].each do |time|
        loan = build :loan, created_at: time

        expect(loan).to be_active
        expect(loan.created_at).to eq time
        expect(loan).not_to be_overdue
        expect(loan.days_overdue).to eq 0
      end
    end

    it 'calculates the number of days accurately' do
      {
        5.minutes.ago => 0,
        p_time('9:20 am NZST') => 0,
        p_time('3:15 pm NZST') - 1.day => 1,
        p_time('4:45 pm NZST') - 3.days => 2,
        p_time('4:45 pm NZST') - 3.days => 2,
        p_time('8:56 am NZST') - 5.days => 5
      }.each_pair do |time, days|
        loan = build :loan, created_at: time
        overdue = days != 0

        expect(loan).to be_active
        expect(loan.overdue?).to eq overdue
        expect(loan.days_overdue).to eq days
      end
    end
  end
end
