# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    text { 'いいね！' }
    association :user
    association :tweet
  end
end
