require 'google_api'
class Channel < ActiveRecord::Base
  has_many :videos

  def fetchVideos
    options = {
      :maxResults => 50,
      :type => "video",
      :order => "viewCount",
      :channelId => youTubeId,
      :part => 'id,snippet'
    }
    search_response = GoogleApi.client.execute!(
      :api_method => GoogleApi.youtube.search.list,
      :parameters => options
    )
    search_response.data.items
  end

  def getStats
  	vid_ids = self.videos.map{|video| video.youtubeVideoId}.join ","

    options = {
      :maxResults => 50,
      :id => vid_ids,
      :part => 'statistics'
    }
    search_response = GoogleApi.client.execute!(
      :api_method => GoogleApi.youtube.videos.list,
      :parameters => options
    )

    search_response.data.items.each do |result|
      video = Video.find_by_youtubeVideoId result.id
      video.stats << VideoStatistic.create do |stat|
        stat.video_id = result.id
        stat.viewCount = result.statistics.viewCount
        stat.likeCount = result.statistics.likeCount
        stat.dislikeCount = result.statistics.dislikeCount
      end
      video.save
    end
  end

  def createVideos
  	videos = fetchVideos
    puts "Checking #{videos.length} videos"
    videos.each do |search_result|
      next if Video.find_by_youtubeVideoId search_result.id.videoId
      self.videos << Video.new do |v|
        v.title = search_result.snippet.title
        v.channel_id = id
        v.youtubeVideoId = search_result.id.videoId
      end
      self.save
    end
    nil
  end
end