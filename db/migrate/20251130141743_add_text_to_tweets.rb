# frozen_string_literal: true

class AddTextToTweets < ActiveRecord::Migration[7.1]
  def change
    add_column :tweets, :text, :text
  end
end
