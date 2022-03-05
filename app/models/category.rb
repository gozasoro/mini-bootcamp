# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :challenges, dependent: :restrict_with_error

  include RankedModel
  ranks :row_order

  EDITOR_MODES = {
    Go: "ace/mode/golang",
    Java: "ace/mode/java",
    JavaScript: "ace/mode/javascript",
    PHP: "ace/mode/php",
    Perl: "ace/mode/perl",
    Python: "ace/mode/python",
    Ruby: "ace/mode/ruby"
  }

  validates :name, presence: true, uniqueness: true
  validates :docker_image, presence: true, uniqueness: true
  validates :editor_mode, inclusion: { in: EDITOR_MODES.values }
  validates :command, presence: true
  validates :extension, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "は英字のみ使えます" }
end
