# frozen_string_literal: true

class Intensity < ActiveHash::Base
  self.data = [
    { id: 1, name: '---' },
    { id: 2, name: 'ゆっくり' },
    { id: 3, name: '普通' },
    { id: 4, name: 'きつめ' }
  ]

  include ActiveHash::Associations
  has_many :tweets
end
