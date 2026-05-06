# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it 'FactoryBotで作ったuserは有効である' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'nicknameが空だと無効' do
      user = build(:user, nickname: '')
      expect(user).to be_invalid
    end

    it 'emailが空だと無効' do
      user = build(:user, email: '')
      expect(user).to be_invalid
    end

    it 'emailが重複すると無効' do
      create(:user, email: 'dup@example.com')
      user = build(:user, email: 'dup@example.com')
      expect(user).to be_invalid
    end

    it 'passwordが6文字未満だと無効' do
      user = build(:user, password: '12345', password_confirmation: '12345')
      expect(user).to be_invalid
    end

    it 'family_name_kana must be katakana' do
      user = build(:user, family_name_kana: 'やまだ')
      user.valid?
      expect(user.errors[:family_name_kana]).to be_present
    end
  end
end
