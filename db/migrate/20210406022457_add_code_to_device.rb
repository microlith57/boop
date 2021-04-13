class AddCodeToDevice < ActiveRecord::Migration[6.1]
  # Ensure Device model exists so we can use it
  class Device < ApplicationRecord
  end

  # :reek:NestedIterators
  # rubocop:disable Rails/SkipsModelValidations
  def change
    add_column :devices, :code, :string
    add_index :devices, :code, unique: true

    reversible do |dir|
      dir.up do
        Device.find_each do |device|
          device.update_attribute(:code, device.name.parameterize)
        end
      end
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
