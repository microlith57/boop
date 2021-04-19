class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :code
      t.belongs_to :parent, foreign_key: { to_table: :groups }

      t.timestamps
    end

    change_table :devices do |t|
      t.belongs_to :group, foreign_key: true
    end
  end
end
