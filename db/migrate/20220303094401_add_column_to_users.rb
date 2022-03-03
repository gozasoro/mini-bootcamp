# frozen_string_literal: true

class AddColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :admin, :boolean, null: false, default: false
  end
end
