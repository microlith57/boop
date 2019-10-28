class CreateBarcodes < ActiveRecord::Migration[6.0]
  def change
    create_table :barcodes do |t|
      t.string :code
      t.references :owner, polymorphic: true, index: { unique: true }

      t.timestamps
    end
    add_index :barcodes, :code, unique: true
  end
end
