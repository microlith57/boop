# frozen_string_literal: true

class CreateLoans < ActiveRecord::Migration[6.0]
  def change
    create_table :loans do |t|
      t.references :issuer, null: false, foreign_key: true
      t.references :device, null: false, foreign_key: true

      t.datetime :issued_at
      t.datetime :returned_at

      t.timestamps
    end
  end
end
