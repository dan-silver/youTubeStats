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

  def self.fetchTopVideos
    options = {
      :maxResults => 50,
      :type => "video",
      :order => "viewCount",
      :part => "id,snippet"
    }
    response = GoogleApi.client.execute!(
      :api_method => GoogleApi.youtube.search.list,
      :parameters => options
    )

    newChannels = []

    response.data.items.each do |video|
      newChannels << video.snippet.channel_id unless Channel.find_by_youTubeId video.snippet.channelId
    end

    options = {
      :maxResults => 50,
      :part => "id,snippet,statistics",
      :id => newChannels.join(",")
    }

    response = GoogleApi.client.execute!(
      :api_method => GoogleApi.youtube.channels.list,
      :parameters => options
    )
    response.data.items.each do |channel|
      Channel.create do |c|
        c.name = channel.snippet.title
        c.youTubeId = channel.id
      end
    end
  end

  def self.getAllVideos
    Channel.all.each {|c| c.createVideos}
  end
end