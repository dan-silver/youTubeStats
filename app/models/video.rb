require 'google_api'
require 'enumerator'
class Video < ActiveRecord::Base
  belongs_to :channel
  has_many :videoStatistics
  has_many :stats, :foreign_key => 'video_id', :class_name => "VideoStatistic"

  def self.getStats
    Video.all.each_slice(50) do |videos|
      vid_ids = videos.map{|video| video.youtubeVideoId}.join ","
      options = {
        :id => vid_ids,
        :part => 'statistics'
      }

      response = GoogleApi.client.execute!(
        :api_method => GoogleApi.youtube.videos.list,
        :parameters => options
      )

      response.data.items.each do |result|
        video = Video.find_by_youtubeVideoId result.id
        VideoStatistic.create do |stat|
          stat.video_id = video.id
          stat.viewCount = result.statistics.viewCount
          stat.likeCount = result.statistics.likeCount
          stat.dislikeCount = result.statistics.dislikeCount
        end
      end

    end
  end
end