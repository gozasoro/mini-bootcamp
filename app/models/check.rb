# frozen_string_literal: true

class Check < ApplicationRecord
  belongs_to :challenge

  validates :stdin, presence: true
  validates :stdout, presence: true
end
