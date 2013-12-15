class FetchDataController < ApplicationController
  def fetchVideos (channelId = 1)
    channel = Channel.find channelId
    
    youtube = googleClient.discovered_api("youtube", "v3")

    opts = Trollop::options do
      opt :maxResults, 'Max results', :default => 50
      opt :type, 'Type', :default => 'video'
      opt :order, 'Order', :default => 'viewCount'
      opt :channelId, 'Channel Id', :default => channel.youTubeId
    end

    opts[:part] = 'id,snippet'
    search_response = googleClient.execute!(
      :api_method => youtube.search.list,
      :parameters => opts
    )
    search_response.data.items
  end

  def getStats (channelId = 1)
  	channel = Channel.find channelId
    vid_ids = channel.videos.map{|video| video.youtubeVideoId}.join ","

    youtube = googleClient.discovered_api "youtube", "v3"

    opts = Trollop::options do
      opt :maxResults, 'Max results', :default => 50
      opt :id, 'Channel Id', :default => vid_ids
    end

    opts[:part] = 'statistics'
    search_response = googleClient.execute!(
      :api_method => youtube.videos.list,
      :parameters => opts
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

  def createVideos (channelId = 1)
  	channel = Channel.find channelId
    videos = fetchVideos channelId
    puts "Checking #{videos.length} videos"
    videos.each do |search_result|
      next if Video.find_by_youtubeVideoId search_result.id.videoId
      channel.videos << Video.new do |v|
        v.title = search_result.snippet.title
        v.channel_id = channelId
        v.youtubeVideoId = search_result.id.videoId
      end
      channel.save
    end
    nil
  end
end