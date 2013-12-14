class CreateVideoStatistics < ActiveRecord::Migration
  def change
    create_table :video_statistics do |t|
      t.references :video, index: true
      t.integer :viewCount
      t.integer :likeCount
      t.integer :dislikeCount

      t.timestamps
    end
  end
end
