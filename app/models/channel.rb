require 'youTubeClient'
require 'batch_save'
require 'enumerator'
class Channel < ActiveRecord::Base
  has_many :videos
  has_many :stats, :foreign_key => 'channel_id', :class_name => "ChannelStat"

  def fetchTopVideos
    options = {
      :type => "video",
      :order => "viewCount",
      :channel_id => youTubeId,
      :max_results => 50
    }
    response = YouTube.client.list_searches("snippet", options)
    ids = Video.all.map {|v| v.youtubeVideoId}
    newVideos = []
    response.items.each do |result|
      next if ids.include? result.id.video_id #Check if we already have the video
      #instantiate a new video, don't save it yet though
      v = Video.new do |v|
        v.title = result.snippet.title
        v.channel_id = id
        v.youtubeVideoId = result.id.video_id
        v.picture = result.snippet.thumbnails.default.url
      end
      newVideos << v
    end
    newVideos.batchSave
  end

  def self.fetchChannelsByTopVideos(videos = 2000)
    remaining = videos
    nextPageToken = nil
    newChannels = []

    until remaining == 0 do
      this_batch_count = [50, remaining].min #50 is the max Google allows per call
      remaining -= this_batch_count
      options = {
        :max_results => this_batch_count,
        :type => "video",
        :order => "viewCount",
        :page_token => nextPageToken
      }
      response = YouTube.client.list_searches("snippet", options)

      nextPageToken = response.next_page_token
      response.items.each do |video|
        newChannels << video.snippet.channel_id unless newChannels.include?(video.snippet.channel_id)
      end
    end

    newChannels -= Channel.all.map {|a| a.youTubeId}

    newChannels.each_slice(50) do |slice|
      options = {
        :id => slice.join(",")
      }

      response = YouTube.client.list_channels("id,snippet", options)

      channels = []
      response.items.each do |channel|
        channels << Channel.new do |c|
          c.name = channel.snippet.title
          c.youTubeId = channel.id
          c.picture = channel.snippet.thumbnails.default.url
        end
      end
      channels.batchSave
    end
  end

  def self.getSubscriberStats
    Channel.all.each_slice(50) do |channels|
      ids = channels.map{|channel| channel.youTubeId}.join ","
      options = {
        :id => ids
      }
      response = YouTube.client.list_channels("statistics", options)
      stats = []
      response.items.each do |result|
        channel = Channel.find_by_youTubeId result.id
        stats << ChannelStat.new do |stat|
          stat.channel_id = channel.id
          stat.subscribers = result.statistics.subscriber_count
        end
      end
      stats.batchSave
    end
  end

  def self.getAllVideos
    Channel.all.each {|c| c.fetchTopVideos}
  end
end