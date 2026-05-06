# frozen_string_literal: true

class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[show edit update destroy]
  before_action :authorize_tweet!, only: %i[edit update destroy]

  def authorize_tweet!
    return if @tweet.user == current_user

    redirect_to root_path, alert: '自分の投稿だけ編集・削除できます。'
  end



  def index
    @tweets = Tweet.order(activity_date: :desc)
end


  def show
    @comment = Comment.new
    @comments = @tweet.comments.includes(:user)
  end

  def new
    @tweet = Tweet.new
  end

  def create
    @tweet = Tweet.new(tweet_params)
    @tweet.user = current_user

    if @tweet.save
      Rails.logger.info "★★★ TWEET CREATED! id=#{@tweet.id} ★★★"
      redirect_to @tweet
    else
      Rails.logger.info "★★★ TWEET SAVE FAILED: #{@tweet.errors.full_messages} ★★★"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    # ① チェックがついた画像を削除
    if params[:tweet][:remove_image_ids].present?
      params[:tweet][:remove_image_ids].each do |attachment_id|
        @tweet.images.find(attachment_id).purge
      end
    end

    # ② 新しくアップロードされた画像があれば「追加」で attach
    if params[:tweet][:images].present?
      params[:tweet][:images].each do |image|
        @tweet.images.attach(image)
      end
    end

    # ③ それ以外の属性（subject, text など）だけ更新する
    #    images はここで扱わないようにするのがポイント！
    if @tweet.update(tweet_params.except(:images))
      redirect_to tweet_path(@tweet), notice: '更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tweet.destroy
    redirect_to tweets_path, notice: '削除しました'
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:id])
  end

  def tweet_params
    params.require(:tweet).permit(
      :subject,
      :activity_date,
      :text,
      :category_id,
      :duration_id,
      :intensity_id,
      :rating_id,
      images: []
    )
  end
end
