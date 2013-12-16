require 'google_api'
require 'enumerator'
class Channel < ActiveRecord::Base
  has_many :videos
  has_many :stats, :foreign_key => 'channel_id', :class_name => "ChannelStat"

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
    newVideos = []
    response.data.items.each do |result|
      next if ids.include? result.id.videoId #Check if we already have the video
      #instantiate a new video, don't save it yet though
      v = Video.new do |v|
        v.title = result.snippet.title
        v.channel_id = id
        v.youtubeVideoId = result.id.videoId
      end
      newVideos << v
    end
    #Save all the videos in one transaction...MUCH FASTER
    Video.transaction do
      newVideos.each do |video|
        video.save
      end
    end
  end

  def self.fetchChannelsByTopVideos(videos = 725)
    remaining = videos
    nextPageToken = nil
    newChannels = []

    until remaining == 0 do
      this_batch_count = [50, remaining].min #50 is the max Google allows per call
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
      channels = []
      response.data.items.each do |channel|
        channels << Channel.new do |c|
          c.name = channel.snippet.title
          c.youTubeId = channel.id
        end
      end

      Channel.transaction do
        channels.each do |channel|
          channel.save
        end
      end

    end
  end

  def self.getAllVideos
    Channel.all.each {|c| c.fetchVideos}
  end
end