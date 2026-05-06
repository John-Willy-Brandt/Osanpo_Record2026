# frozen_string_literal: true

class Rating < ActiveHash::Base
  self.data = [
    { id: 1, name: '---' },
    { id: 2, name: '最高！' },
    { id: 3, name: '普通' },
    { id: 4, name: 'いまいち…' }
  ]

  include ActiveHash::Associations
  has_many :tweets
end
