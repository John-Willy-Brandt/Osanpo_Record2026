# frozen_string_literal: true

class RenameWalkedOnToActivityDateInTweets < ActiveRecord::Migration[7.1]
  def change
    rename_column :tweets, :walked_on, :activity_date
  end
end
