class RemovefavoriteCountFromVideoStatistic < ActiveRecord::Migration
  def change
  	remove_column :video_statistics, :favoriteCount
  end
end
