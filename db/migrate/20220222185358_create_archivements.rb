# frozen_string_literal: true

class CreateArchivements < ActiveRecord::Migration[6.1]
  def change
    create_table :archivements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :challenge, null: false, foreign_key: true

      t.timestamps
    end

    add_index :archivements, %i(user_id challenge_id), unique: true
  end
end
