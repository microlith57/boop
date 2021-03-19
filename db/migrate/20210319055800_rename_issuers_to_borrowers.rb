class RenameIssuersToBorrowers < ActiveRecord::Migration[6.1]
  def change
    rename_table :issuers, :borrowers
    rename_column :loans, :issuer_id, :borrower_id
  end
end
