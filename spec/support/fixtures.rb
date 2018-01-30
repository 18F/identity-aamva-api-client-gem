require 'openssl'

module Fixtures
  def self.aamva_private_key
    raw = read_fixture_file('keys/aamva-private-key.example.pem')
    OpenSSL::PKey::RSA.new(raw, 'sekret')
  end

  def self.aamva_public_key
    raw = read_fixture_file('keys/aamva-public-key.example.crt')
    OpenSSL::X509::Certificate.new(raw)
  end

  def self.aamva_test_data
    read_fixture_file('aamva_test_data.csv')
  end

  def self.authentication_token_request
    read_fixture_file('requests/authentication_token_request.xml').
      gsub(/^\s+/, '').
      gsub(/\s+$/, '').
      delete("\n") + "\n"
  end

  def self.authentication_token_response
    read_fixture_file('responses/authentication_token_response.xml')
  end

  def self.security_token_request
    read_fixture_file('requests/security_token_request.xml').
      gsub(/^\s+/, '').
      gsub(/\s+$/, '').
      delete("\n") + "\n"
  end

  def self.security_token_response
    read_fixture_file('responses/security_token_response.xml')
  end

  def self.soap_fault_response
    read_fixture_file('responses/soap_fault_response.xml')
  end

  def self.soap_fault_response_simplified
    XmlHelpers.delete_xml_at_xpath(
      soap_fault_response,
      '//ProgramExceptions'
    )
  end

  def self.verification_request
    read_fixture_file('requests/verification_request.xml').
      gsub(/^\s+/, '').
      gsub(/\s+$/, '').
      delete("\n")
  end

  def self.verification_response
    read_fixture_file('responses/verification_response.xml')
  end

  private_class_method def self.read_fixture_file(path)
    fullpath = File.join(
      File.dirname(__FILE__),
      '../fixtures',
      path
    )
    File.read(fullpath)
  end
end
