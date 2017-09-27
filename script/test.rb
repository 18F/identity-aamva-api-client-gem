require 'dotenv'

require 'pry-byebug'

Dotenv.load(File.expand_path('../.env', File.dirname(__FILE__)))

$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

public_pem_path = File.expand_path(ENV['AAMVA_PUBLIC_KEY_PATH'])
private_pem_path = File.expand_path(ENV['AAMVA_PRIVATE_KEY_PATH'])
cert_password = ENV['AAMVA_PRIVATE_KEY_PASSPHRASE']

require 'savon'
require 'logger'
require 'aamva'

request = Aamva::Request::AuthenticationRequest.new

puts request.headers
puts request.body
response = HTTPI.post(request)
puts response.body
binding.pry
