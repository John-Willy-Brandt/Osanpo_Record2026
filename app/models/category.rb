# frozen_string_literal: true

class Category < ActiveHash::Base
  self.data = [
    { id: 1, name: '---' },
    { id: 2, name: 'お散歩' },
    { id: 3, name: 'ランニング' },
    { id: 4, name: 'ジョギング' },
    { id: 5, name: 'ハイキング' },
    { id: 6, name: '登山' }
  ]

  include ActiveHash::Associations
  has_many :tweets
end
