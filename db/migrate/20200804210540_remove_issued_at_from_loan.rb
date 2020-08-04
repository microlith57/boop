class RemoveIssuedAtFromLoan < ActiveRecord::Migration[6.0]
  def change
    remove_column :loans, :issued_at, :datetime
  end
end
