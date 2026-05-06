# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tweet, only: :create

  def create
    # 投稿者はコメント禁止
    if current_user.id == @tweet.user_id
      redirect_to tweet_path(@tweet), alert: '投稿者はこの投稿にコメントできません。'
      return
    end

    @comment = @tweet.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to tweet_path(@tweet)
    else
      # バリデーションエラー時にコメント一覧を再表示するため
      @comments = @tweet.comments.includes(:user)
      flash.now[:alert] = 'コメントを投稿できませんでした。'
      render 'tweets/show', status: :unprocessable_entity
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end

  def comment_params
    # text だけを受け取る。user_id と tweet_id はサーバ側でセットする
    params.require(:comment).permit(:text)
  end
end
