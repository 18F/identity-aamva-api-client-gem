# use local 'lib' dir in include path
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'pry-byebug'
require 'webmock/rspec'
require 'retries'

require 'aamva'

Dir[File.dirname(__FILE__) + '/support/*.rb'].sort.each { |file| require file }

Retries.sleep_enabled = false

def example_config
  Aamva::Proofer::Config.new(
    cert_enabled: 'false',
    private_key: Base64.strict_encode64(Fixtures.aamva_private_key.to_der),
    public_key: Base64.strict_encode64(Fixtures.aamva_public_key.to_der),
    verification_url: 'https://verificationservices-primary.example.com:18449/dldv/2.1/valuefree',
    auth_url: 'https://authentication-cert.example.com/Authentication/Authenticate.svc',
  )
end

RSpec.configure do |config|
  config.color = true
  config.example_status_persistence_file_path = './tmp/rspec-examples.txt'
  config.include XmlHelpers
  config.before(:all) do
    WebMock.reset!
  end
end
