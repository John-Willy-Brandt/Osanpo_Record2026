# frozen_string_literal: true

class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[show edit update destroy rotate_image destroy_image]
  before_action :authorize_tweet!, only: %i[edit update destroy rotate_image destroy_image]

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
    if params[:tweet][:images].present?
      params[:tweet][:images].each do |image|
        @tweet.images.attach(image)
      end
    end

    if @tweet.update(tweet_params.except(:images))
      redirect_to tweet_path(@tweet), notice: '更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy_image
    @tweet.images.find(params[:image_id]).purge
    redirect_to edit_tweet_path(@tweet), notice: '写真を削除しました'
  end

  def rotate_image
    attachment = @tweet.images.find(params[:image_id])
    degrees = params[:direction] == 'ccw' ? -90 : 90

    Tempfile.create(['rotated', ".#{attachment.filename.extension}"]) do |tmp|
      tmp.binmode
      tmp.write(attachment.download)
      tmp.rewind

      rotated_path = ImageProcessing::MiniMagick
        .source(tmp.path)
        .rotate(degrees)
        .call

      filename = attachment.filename.to_s
      content_type = attachment.content_type
      attachment.purge
      @tweet.images.attach(
        io: File.open(rotated_path),
        filename: filename,
        content_type: content_type
      )
    end

    redirect_to edit_tweet_path(@tweet), notice: '写真を回転しました'
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
