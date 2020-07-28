# frozen_string_literal: true

class RemoveIssuedAtFromDevice < ActiveRecord::Migration[6.0]
  def change
    remove_column :devices, :issued_at, :datetime
  end
end
