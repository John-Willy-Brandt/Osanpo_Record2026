# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tweets, dependent: :destroy
  has_many :comments, dependent: :destroy

  # ===== 正規表現 =====
  JAPANESE_NAME_REGEX = /\A[ぁ-んァ-ヶ一-龥々]+\z/
  KATAKANA_REGEX      = /\A[ァ-ヶー・]+\z/

  # ===== presence =====
  with_options presence: true do
    validates :nickname
    validates :family_name
    validates :first_name
    validates :family_name_kana
    validates :first_name_kana
    validates :birthday
  end

  # ===== format =====
  validates :family_name, format: {
    with: JAPANESE_NAME_REGEX,
    message: 'は漢字・ひらがな・カタカナのみで入力してください'
  }

  validates :first_name, format: {
    with: JAPANESE_NAME_REGEX,
    message: 'は漢字・ひらがな・カタカナのみで入力してください'
  }

  validates :family_name_kana, format: {
    with: KATAKANA_REGEX,
    message: 'は全角カタカナで入力してください'
  }

  validates :first_name_kana, format: {
    with: KATAKANA_REGEX,
    message: 'は全角カタカナで入力してください'
  }
end
