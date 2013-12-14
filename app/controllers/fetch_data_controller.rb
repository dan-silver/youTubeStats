class FetchDataController < ApplicationController
  def fetchVideos (channelId = 1)
  	channel = Channel.find channelId
  	
  	client = createGoogleClient

    youtube = client.discovered_api("youtube", "v3")

    opts = Trollop::options do
      opt :maxResults, 'Max results', :default => 50
      opt :type, 'Type', :default => 'video'
      opt :order, 'Order', :default => 'viewCount'
      opt :channelId, 'Channel Id', :default => channel.youTubeId
    end

    opts[:part] = 'id,snippet'
    search_response = client.execute!(
      :api_method => youtube.search.list,
      :parameters => opts
    )

    search_response.data.items.each do |search_result|
      channel.videos << Video.new do |v|
        v.title = search_result.snippet.title
        v.channel_id = channelId
      end
      channel.save

    end
  end

  def createGoogleClient
    client = Google::APIClient.new(
      :application_name => 'Example Ruby application',
      :application_version => '1.0.0'
    )

    key = Google::APIClient::PKCS12.load_key '../youtube/client.p12', 'notasecret'
        service_account = Google::APIClient::JWTAsserter.new(
            ENV['GOOGLE_KEY'],
            'https://www.googleapis.com/auth/youtube',
             key)
    client.authorization = service_account.authorize
    client
  end
end