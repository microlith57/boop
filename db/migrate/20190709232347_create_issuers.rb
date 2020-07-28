class CreateIssuers < ActiveRecord::Migration[5.2]
  def change
    create_table :issuers do |t|
      t.string  :name
      t.string  :email
      t.string  :barcode
      t.integer :allowance

      t.timestamps
    end
    add_index :issuers, :barcode, unique: true
  end
end
