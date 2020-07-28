class AddSaltToDevice < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :salt, :string
  end
end
