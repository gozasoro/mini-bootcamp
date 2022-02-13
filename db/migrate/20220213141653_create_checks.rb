# frozen_string_literal: true

class CreateChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :checks do |t|
      t.text :stdin, null: false
      t.text :stdout, null: false
      t.references :challenge, null: false, foreign_key: true

      t.timestamps
    end
  end
end
