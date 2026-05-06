# frozen_string_literal: true

FactoryBot.define do
  factory :tweet do
    subject { '朝ラン' }
    text { '今日は5km走った！' }
    activity_date { Date.today }

    # ActiveHash（あなたの定義が「1は---」なら2以上が安全）
    category_id { 2 }
    duration_id { 2 }
    intensity_id { 2 }
    rating_id { 2 }

    memo { '気持ちよかった' }

    association :user
  end
end
