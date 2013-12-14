class AddYoutubevideoIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :youtubeVideoId, :string
  end
end
