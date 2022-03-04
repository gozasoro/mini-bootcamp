# frozen_string_literal: true

class ChangeNotNullToChecks < ActiveRecord::Migration[6.1]
  def up
    change_column_null :checks, :stdin, true
  end

  def down
    change_column_null :checks, :stdin, false
  end
end
