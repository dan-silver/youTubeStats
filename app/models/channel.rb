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
    response = GoogleApi.client.execute!(
      :api_method => GoogleApi.youtube.search.list,
      :parameters => options
    )
    response.data.items
  end

  def getStats
  	vid_ids = self.videos.map{|video| video.youtubeVideoId}.join ","

    options = {
      :maxResults => 50,
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

  def createVideos
  	videos = fetchVideos
    puts "Checking #{videos.length} videos"
    videos.each do |search_result|
      next if Video.find_by_youtubeVideoId search_result.id.videoId
      Video.create do |v|
        v.title = search_result.snippet.title
        v.channel_id = id
        v.youtubeVideoId = search_result.id.videoId
      end
    end
    nil
  end
end