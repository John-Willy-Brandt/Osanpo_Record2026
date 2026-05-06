# frozen_string_literal: true

class Tweet < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user

  belongs_to :category
  belongs_to :duration
  belongs_to :intensity
  belongs_to :rating

  has_many_attached :images
  has_many :comments

  validates :subject, :text, :activity_date, presence: true
  validates :category_id, :duration_id, :intensity_id, :rating_id,
            numericality: { other_than: 1, message: 'を選択してください' }
end
