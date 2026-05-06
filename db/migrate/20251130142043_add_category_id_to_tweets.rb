# frozen_string_literal: true

class AddCategoryIdToTweets < ActiveRecord::Migration[7.1]
  def change
    add_column :tweets, :category_id, :integer
  end
end
