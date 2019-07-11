class AddCodeToIssuers < ActiveRecord::Migration[5.2]
  def change
    add_column :issuers, :code, :string
    add_index :issuers, :code, unique: true
  end
end
