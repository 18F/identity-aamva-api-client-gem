require 'webmock'
require 'webmock/rspec'

include WebMock::API
WebMock.enable!

module WebMockHelpers
  def reset_webmock
    WebMock.reset!
  end

  def stub_authentication_token_request
    url = Aamva::Request::AuthenticationTokenRequest.auth_url
    stub_request(:post, url).
      with(body: Fixtures.authentication_token_request).
      to_return(body: Fixtures.authentication_token_response, status: 200)
  end

  def stub_security_token_request
    url = Aamva::Request::SecurityTokenRequest.auth_url
    stub_request(:post, url).
      with(body: Fixtures.security_token_request).
      to_return(body: Fixtures.security_token_response, status: 200)
  end

  def stub_verification_request
    url = Aamva::Request::VerificationRequest.verification_url
    response_body = Fixtures.verification_response
    stub_request(:post, url).to_return(body: response_body, status: 200)
  end
end
