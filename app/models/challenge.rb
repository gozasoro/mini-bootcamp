# frozen_string_literal: true

class Challenge < ApplicationRecord
  belongs_to :category
  has_many :checks, dependent: :destroy, inverse_of: :challenge
  accepts_nested_attributes_for :checks, reject_if: :all_blank, allow_destroy: true

  include RankedModel
  ranks :row_order, with_same: :category_id

  validates :title, presence: true, uniqueness: { scope: :category_id }
  validates :content, presence: true
  validates :model_answer, presence: true

  validates :checks, presence: true, length: { in: 1..10, too_long: "は最大10個までです", too_short: "は1個以上必要です"}

  def previous
    Challenge.rank(:row_order).all.where("row_order < ? AND category_id = ?", row_order, category_id).reverse.first
  end

  def next
    Challenge.rank(:row_order).all.where("row_order > ? AND category_id = ?", row_order, category_id).first
  end
end
