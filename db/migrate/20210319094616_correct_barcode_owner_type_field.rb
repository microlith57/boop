class CorrectBarcodeOwnerTypeField < ActiveRecord::Migration[6.1]
  def up
    Barcode.connection.execute <<-SQL
      UPDATE barcodes SET owner_type = 'Borrower' WHERE owner_type = 'Issuer'
    SQL
  end

  def down
    Barcode.connection.execute <<-SQL
      UPDATE barcodes SET owner_type = 'Issuer' WHERE owner_type = 'Borrower'
    SQL
  end
end
