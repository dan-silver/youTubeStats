module GoogleApi
  require 'net/http'
  require 'open-uri'

  def self.fetchKey
    require 'open-uri'
    open('downloaded-key.p12', 'wb') do |file|
      file << open(ENV['GOOGLE_KEY_FILE_URL']).read
    end
  end



  def self.client
    GoogleApi.fetchKey
    client = Google::APIClient.new(
      :application_name => 'Example Ruby application',
      :application_version => '1.0.0'
    )

    key = Google::APIClient::PKCS12.load_key "downloaded-key.p12", 'notasecret'
    service_account = Google::APIClient::JWTAsserter.new(
      ENV['GOOGLE_KEY'],
      'https://www.googleapis.com/auth/youtube',
      key)
    client.authorization = service_account.authorize
    client
  end

  def self.youtube
    GoogleApi.client.discovered_api "youtube", "v3"
  end
end