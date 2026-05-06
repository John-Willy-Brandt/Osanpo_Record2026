# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tweet, type: :model do
  describe 'バリデーション' do
    it 'FactoryBotで作ったtweetは有効である' do
      tweet = build(:tweet)
      expect(tweet).to be_valid
    end

    it 'subjectが空だと無効' do
      tweet = build(:tweet, subject: '')
      expect(tweet).to be_invalid
      expect(tweet.errors.full_messages).to include("Subject can't be blank")
    end

    it 'textが空だと無効' do
      tweet = build(:tweet, text: '')
      expect(tweet).to be_invalid
      expect(tweet.errors.full_messages).to include("Text can't be blank")
    end

    it 'activity_dateが空だと無効' do
      tweet = build(:tweet, activity_date: nil)
      expect(tweet).to be_invalid
      expect(tweet.errors.full_messages).to include("Activity date can't be blank")
    end

    it 'category_id が 1（---）だと無効' do
      tweet = build(:tweet, category_id: 1)
      tweet.valid?
      expect(tweet.errors.full_messages.join).to match(/Category|category/)
    end

    it 'duration_id が 1（---）だと無効' do
      tweet = build(:tweet, duration_id: 1)
      tweet.valid?
      expect(tweet.errors.full_messages.join).to match(/Duration|duration/)
    end

    it 'intensity_id が 1（---）だと無効' do
      tweet = build(:tweet, intensity_id: 1)
      tweet.valid?
      expect(tweet.errors.full_messages.join).to match(/Intensity|intensity/)
    end

    it 'rating_id が 1（---）だと無効' do
      tweet = build(:tweet, rating_id: 1)
      tweet.valid?
      expect(tweet.errors.full_messages.join).to match(/Rating|rating/)
    end
  end
end
