# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tweets CRUD', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'POST /tweets' do
    context 'ログインしているとき' do
      before { sign_in user }

      it '正しいパラメータなら投稿できる（レコードが1増える）' do
        tweet_params = {
          tweet: attributes_for(:tweet) # factoryの内容をそのまま使う
        }

        expect do
          post tweets_path, params: tweet_params
        end.to change(Tweet, :count).by(1)

        # 成功時の挙動（あなたの実装に合わせてどちらかが通るはず）
        expect(response).to have_http_status(:found).or have_http_status(:see_other).or have_http_status(:redirect)

        # ログインユーザーの投稿になっていること（権限の核）
        expect(Tweet.last.user_id).to eq(user.id)
      end

      it '不正なパラメータなら投稿できない（レコードが増えない）' do
        invalid = attributes_for(:tweet, subject: '') # subject必須を利用

        expect do
          post tweets_path, params: { tweet: invalid }
        end.not_to change(Tweet, :count)

        # 実装により 422 / 200（render） / 302（redirect）などあり得るので幅を持たせる
        expect([200, 302, 303, 422]).to include(response.status)
      end
    end

    context 'ログインしていないとき' do
      it '投稿できず、ログイン画面へリダイレクトされる' do
        tweet_params = { tweet: attributes_for(:tweet) }

        expect do
          post tweets_path, params: tweet_params
        end.not_to change(Tweet, :count)

        expect(response).to have_http_status(:found).or have_http_status(:see_other).or have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /tweets/:id' do
    let!(:tweet) { create(:tweet, user: user) }

    context 'ログインしているとき' do
      it '自分の投稿は更新できる' do
        sign_in user

        update_params = {
          tweet: { subject: '更新後タイトル' }
        }

        patch tweet_path(tweet), params: update_params

        expect(response).to have_http_status(:found).or have_http_status(:see_other).or have_http_status(:redirect)

        tweet.reload
        expect(tweet.subject).to eq('更新後タイトル')
      end

      it '他人の投稿は更新できない（権限チェック）' do
        sign_in other_user

        update_params = {
          tweet: { subject: '不正更新' }
        }

        patch tweet_path(tweet), params: update_params

        # 実装により 302/303/403 などあり得る
        expect([302, 303, 403]).to include(response.status)

        tweet.reload
        expect(tweet.subject).not_to eq('不正更新')
      end
    end

    context 'ログインしていないとき' do
      it '更新できず、ログイン画面へリダイレクトされる' do
        update_params = {
          tweet: { subject: '未ログイン更新' }
        }

        patch tweet_path(tweet), params: update_params

        expect(response).to have_http_status(:found).or have_http_status(:see_other).or have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)

        tweet.reload
        expect(tweet.subject).not_to eq('未ログイン更新')
      end
    end
  end

  describe 'DELETE /tweets/:id' do
    let!(:tweet) { create(:tweet, user: user) }

    context 'ログインしているとき' do
      it '自分の投稿は削除できる' do
        sign_in user

        expect do
          delete tweet_path(tweet)
        end.to change(Tweet, :count).by(-1)

        expect(response).to have_http_status(:found).or have_http_status(:see_other).or have_http_status(:redirect)
      end

      it '他人の投稿は削除できない（権限チェック）' do
        sign_in other_user

        expect do
          delete tweet_path(tweet)
        end.not_to change(Tweet, :count)

        # 実装により 302で一覧へ戻す/トップへ戻す、403を返す等があり得るので幅を持たせる
        expect([302, 303, 403]).to include(response.status)
      end
    end

    context 'ログインしていないとき' do
      it '削除できず、ログイン画面へリダイレクトされる' do
        expect do
          delete tweet_path(tweet)
        end.not_to change(Tweet, :count)

        expect(response).to have_http_status(:found).or have_http_status(:see_other).or have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
