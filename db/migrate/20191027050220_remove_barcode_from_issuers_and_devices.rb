class RemoveBarcodeFromIssuersAndDevices < ActiveRecord::Migration[6.0]
  def change
    remove_column :issuers, :barcode, :string
    remove_column :devices, :barcode, :string

    remove_column :issuers, :salt, :string
    remove_column :devices, :salt, :string
  end
end
