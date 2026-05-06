# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    nickname { 'john' }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { password }

    family_name { '山田' }
    first_name  { '太郎' }
    family_name_kana { 'ヤマダ' }
    first_name_kana  { 'タロウ' }
    birthday { Date.new(1990, 1, 1) }
  end
end
