module GoogleApiUtils
  def self.google_client
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
    Channel.googleClient = client
  end
end