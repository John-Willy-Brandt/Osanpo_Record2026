# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'バリデーション' do
    it 'FactoryBotで作ったcommentは有効である' do
      comment = build(:comment)
      expect(comment).to be_valid
    end

    it 'textが空だと無効' do
      comment = build(:comment, text: '')
      expect(comment).to be_invalid
    end

    it 'userが紐づいていないと無効' do
      comment = build(:comment, user: nil)
      expect(comment).to be_invalid
    end

    it 'tweetが紐づいていないと無効' do
      comment = build(:comment, tweet: nil)
      expect(comment).to be_invalid
    end
  end
end
