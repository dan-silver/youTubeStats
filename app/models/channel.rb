require 'google_api'
require 'enumerator'
class Channel < ActiveRecord::Base
  has_many :videos

  def fetchVideos
    options = {
      :type => "video",
      :order => "viewCount",
      :channelId => youTubeId,
      :part => 'id,snippet',
      :maxResults => 50
    }
    response = GoogleApi.client.execute!(
      :api_method => GoogleApi.youtube.search.list,
      :parameters => options
    )
    ids = Video.all.map {|v| v.youtubeVideoId}
    response.data.items.each do |result|
      next if ids.include? result.id.videoId
      Video.create do |v|
        v.title = result.snippet.title
        v.channel_id = id
        v.youtubeVideoId = result.id.videoId
      end
    end
  end

  def self.fetchChannelsByTopVideos(videos = 50)
    remaining = videos
    nextPageToken = nil
    newChannels = []

    until remaining == 0 do
      this_batch_count = [50, remaining].min
      remaining -= this_batch_count
      options = {
        :maxResults => this_batch_count,
        :type => "video",
        :order => "viewCount",
        :part => "id,snippet",
        :pageToken => nextPageToken
      }
      response = GoogleApi.client.execute!(
        :api_method => GoogleApi.youtube.search.list,
        :parameters => options
      )

      nextPageToken = response.data.nextPageToken
      response.data.items.each do |video|
        newChannels << video.snippet.channel_id unless newChannels.include?(video.snippet.channel_id)
      end
    end
    newChannels -= Channel.all.map {|a| a.youTubeId}

    newChannels.each_slice(50) do |slice|
      options = {
        :part => "id,snippet,statistics",
        :id => slice.join(",")
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
  end

  def self.getAllVideos
    Channel.all.each {|c| c.fetchVideos}
  end
end