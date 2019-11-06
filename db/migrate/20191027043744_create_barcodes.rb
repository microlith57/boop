class CreateBarcodes < ActiveRecord::Migration[6.0]
  # :reek:FeatureEnvy
  # :reek:UncommunicativeVariableName
  def change
    create_table :barcodes do |t|
      t.string :code

      # Disable the index here on the reference...
      t.references :owner,
                   polymorphic: true,
                   index: false
      #  ...then create it manually with a `UNIQUE` constraint
      t.index %w[owner_type owner_id],
              name: 'index_barcodes_on_owner_type_and_owner_id',
              unique: true

      t.timestamps
    end
    add_index :barcodes, :code, unique: true
  end
end
