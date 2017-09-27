require 'httpi'

module Aamva
  class AuthenticationClient
    AAMVA_TOKEN_FRESHNESS_SECONDS = 28 * 60

    class << self
      attr_accessor :auth_token
      attr_accessor :auth_token_expiration
    end

    def self.token_mutex
      @token_mutex ||= Mutex.new
    end

    def fetch_token
      AuthenticationClient.token_mutex.synchronize do
        if AuthenticationClient.auth_token.nil? || auth_token_expired?
          send_auth_token_request
        end
        AuthenticationClient.auth_token
      end
    end

    private

    def send_auth_token_request
      sct_request = Request::SecurityTokenRequest.new
      sct_response = Response::SecurityTokenResponse.new(HTTPI.post(sct_request))
      token_request = Request::AuthenticationTokenRequest.new(
        security_context_token_identifier: sct_response.security_context_token_identifier,
        security_context_token_reference: sct_response.security_context_token_reference,
        client_hmac_secret: sct_request.nonce, server_hmac_secret: sct_response.nonce
      )
      token_response = Response::AuthenticationTokenResponse.new(HTTPI.post(token_request))
      AuthenticationClient.auth_token = token_response.auth_token
      AuthenticationClient.auth_token_expiration = Time.now + AAMVA_TOKEN_FRESHNESS_SECONDS
    end

    def auth_token_expired?
      (AuthenticationClient.auth_token_expiration - Time.now).negative?
    end
  end
end
