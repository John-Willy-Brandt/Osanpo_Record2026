# frozen_string_literal: true

class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user

    # ログインユーザーのツイート（画像付きもまとめて読み込む）
    @tweets = @user.tweets
                   .with_attached_images
                   .order(activity_date: :asc)

    # ✅ 日付ごとにツイートをまとめる（カレンダー用）
    @tweets_by_date = @tweets.group_by { |t| t.activity_date.to_date }

    # ✅ おさんぽした日付の一覧（背景色やマーク用）
    @activity_dates = @tweets_by_date.keys
  end
end
