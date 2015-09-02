class ChangeViewCountType < ActiveRecord::Migration
  def change
    change_column :video_statistics, :viewCount, :bigint  	
  end
end
