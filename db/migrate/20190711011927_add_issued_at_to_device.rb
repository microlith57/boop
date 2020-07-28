class AddIssuedAtToDevice < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :issued_at, :datetime
  end
end
