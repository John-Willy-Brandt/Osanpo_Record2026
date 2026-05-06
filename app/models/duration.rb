# frozen_string_literal: true

class Duration < ActiveHash::Base
  self.data = [
    { id: 1, name: '---' },
    { id: 2, name: '0〜30分' },
    { id: 3, name: '30〜60分' },
    { id: 4, name: '60分以上' }
  ]

  include ActiveHash::Associations
  has_many :tweets
end
