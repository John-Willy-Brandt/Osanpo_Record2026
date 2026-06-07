# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root 'tweets#index'

  # マイページ（自分専用ページ）へのショートカット
  get 'mypage', to: 'mypages#show', as: :mypage

  # ★ ユーザー個別ページ（/users/:id）
  resources :users, only: :show

  resources :tweets do
    resources :comments, only: :create
    member do
      post   :rotate_image
      delete :destroy_image
    end
  end
end
