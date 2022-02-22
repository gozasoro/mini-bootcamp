# frozen_string_literal: true

class Archivement < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  validates :user_id, uniqueness: { scope: :challenge_id }
end
