# frozen_string_literal: true

class CreateTweets < ActiveRecord::Migration[7.1]
  def change
    create_table :tweets do |t|
      t.string  :subject,     null: false
      t.date    :walked_on,   null: false
      t.integer :duration_id, null: false
      t.integer :intensity_id, null: false
      t.integer :rating_id, null: false
      t.text    :memo
      t.references :user, null: false # , foreign_key: true

      t.timestamps
    end
  end
end
