require 'google_api'
require 'enumerator'
class Channel < ActiveRecord::Base
  has_many :videos

  def fetchVideos
    total = 1
    completed = 0
    nextPageToken = nil
    until completed >= total do
      options = {
        :type => "video",
        :channelId => youTubeId,
        :part => 'id,snippet',
        :pageToken => nextPageToken,
        :maxResults => 50
      }
      response = GoogleApi.client.execute!(
        :api_method => GoogleApi.youtube.search.list,
        :parameters => options
      )

      response.data.items.each do |result|
        next if Video.find_by_youtubeVideoId result.id.videoId
        Video.create do |v|
          v.title = result.snippet.title
          v.channel_id = id
          v.youtubeVideoId = result.id.videoId
        end
      end
      total = response.data.pageInfo.totalResults
      nextPageToken = response.data.nextPageToken if response.data.items.length == 50 
      completed += response.data.items.length
      puts "#{completed}/#{total}\n"*10
    end
    nil
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