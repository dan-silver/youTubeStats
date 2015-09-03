class AddMoreStatsToVideos < ActiveRecord::Migration
  def self.up
  	add_column :video_statistics, :favoriteCount, :integer
  	add_column :video_statistics, :commentCount, :integer
  end
end
