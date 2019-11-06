# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Device do
  context 'overdue logic' do
    around do |example|
      Timecop.freeze DateTime.parse('3:00 pm NZST')
      example.run
      Timecop.return
    end

    it 'can find overdue devices' do
      [
        p_time('4:25 pm NZST') - 1.day,
        p_time('3:15 pm NZST') - 1.day,
        p_time('8:56 am NZST') - 1.day,
        3.days.ago,
        p_time('4:45 pm NZST') - 2.days
      ].each do |time|
        device = build :issued_device, issued_at: time
        expect(device.overdue?)
          .to be_truthy,
              "device issued at #{device.issued_at.to_s(:short)} " \
              "wasn't detected as overdue at #{DateTime.current.to_s(:short)}"
      end
    end

    it 'can find non-overdue devices' do
      [
        p_time('2:00 pm NZST'),
        p_time('9:20 am NZST'),
        p_time('12:00 pm NZST'),
        p_time('4:45 pm NZST') - 1.day,
        5.minutes.ago
      ].each do |time|
        device = build :issued_device, issued_at: time
        expect(device.overdue?).to be_falsey
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
        device = build :issued_device, issued_at: time
        expect(device.days_overdue).to eq days
      end
    end
  end
end
