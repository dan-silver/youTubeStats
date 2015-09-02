module YouTube
  def self.client
    require 'google/apis/youtube_v3'
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = ENV['GOOGLE_KEY']
    return youtube
  end
end