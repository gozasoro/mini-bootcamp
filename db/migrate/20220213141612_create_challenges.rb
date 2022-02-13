# frozen_string_literal: true

class CreateChallenges < ActiveRecord::Migration[6.1]
  def change
    create_table :challenges do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.text :model_answer, null: false
      t.integer :row_order
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :challenges, %i(title category_id), unique: true
  end
end
