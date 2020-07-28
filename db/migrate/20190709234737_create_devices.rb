class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :description
      t.string :barcode
      t.references :issuer, foreign_key: true, index: true

      t.timestamps
    end
    add_index :devices, :barcode, unique: true
  end
end
