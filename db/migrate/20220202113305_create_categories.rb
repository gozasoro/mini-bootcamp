# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :docker_image, null: false
      t.string :command, null: false
      t.string :extension, null: false
      t.string :editor_mode, null: false
      t.integer :row_order

      t.timestamps
    end

    add_index :categories, :name, unique: true
  end
end
