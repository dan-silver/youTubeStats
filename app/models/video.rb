require 'youTubeClient'
require 'batch_save'
require 'enumerator'

class Video < ActiveRecord::Base
  belongs_to :channel
  has_many :stats, :foreign_key => 'video_id', :class_name => "VideoStatistic"

  def self.getStats
    Video.all.each_slice(50) do |videos|
      vid_ids = videos.map{|video| video.youtubeVideoId}.join ","
      options = {
        :id => vid_ids
      }

      response = YouTube.client.list_videos("statistics", options)

      stats = []
      response.items.each do |result|
        video = Video.find_by_youtubeVideoId result.id
        stats << VideoStatistic.new do |stat|
          stat.video_id = video.id
          stat.viewCount = result.statistics.view_count
          stat.likeCount = result.statistics.like_count
          stat.dislikeCount = result.statistics.dislike_count
        end
      end
      stats.batchSave
    end
  end
end