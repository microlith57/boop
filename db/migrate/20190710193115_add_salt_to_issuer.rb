class AddSaltToIssuer < ActiveRecord::Migration[5.2]
  def change
    add_column :issuers, :salt, :string
  end
end
