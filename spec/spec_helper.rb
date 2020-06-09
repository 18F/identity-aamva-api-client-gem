# use local 'lib' dir in include path
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'pry-byebug'
require 'dotenv'
require 'webmock/rspec'
require 'retries'

require 'proofer'
require 'aamva'

Dir[File.dirname(__FILE__) + '/support/*.rb'].sort.each { |file| require file }

EnvOverrides.set_test_environment_variables
Retries.sleep_enabled = false

RSpec.configure do |config|
  config.color = true
  config.example_status_persistence_file_path = './tmp/rspec-examples.txt'
  config.include XmlHelpers
  config.before(:all) do
    WebMock.reset!
  end
end
