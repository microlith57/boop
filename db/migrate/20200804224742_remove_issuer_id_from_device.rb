class RemoveIssuerIdFromDevice < ActiveRecord::Migration[6.0]
  def change
    remove_reference :devices, :issuer, null: false, foreign_key: true
  end
end
