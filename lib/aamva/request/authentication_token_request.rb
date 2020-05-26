require 'base64'
require 'erb'
require 'faraday'
require 'openssl'
require 'securerandom'
require 'time'
require 'typhoeus/adapters/faraday'
require 'xmldsig'

module Aamva
  module Request
    class AuthenticationTokenRequest
      DEFAULT_AUTH_URL = 'https://authentication-cert.aamva.org/Authentication/Authenticate.svc'.freeze
      CONTENT_TYPE = 'application/soap+xml;charset=UTF-8'.freeze
      SOAP_ACTION =
        '"http://aamva.org/authentication/3.1.0/IAuthenticationService/Authenticate"'.freeze

      attr_reader :body, :headers, :url
      attr_reader :security_context_token_identifier, :security_context_token_reference

      def initialize(
        security_context_token_identifier:,
        security_context_token_reference:,
        client_hmac_secret:,
        server_hmac_secret:
      )
        self.security_context_token_identifier = security_context_token_identifier
        self.security_context_token_reference = security_context_token_reference
        self.hmac_secret = HmacSecret.new(client_hmac_secret, server_hmac_secret).psha1
        @url = AuthenticationTokenRequest.auth_url
        @body = build_request_body
        @headers = build_request_headers
      end

      def send
        Response::AuthenticationTokenResponse.new(
          http_client.post(url, body, headers),
        )
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
        message = "AAMVA raised #{e.class} waiting for authentication token response: #{e.message}"
        raise ::Proofer::TimeoutError, message
      end

      def self.auth_url
        Env.fetch('AAMVA_AUTH_URL', DEFAULT_AUTH_URL)
      end

      private

      attr_accessor :hmac_secret
      attr_writer :security_context_token_identifier, :security_context_token_reference

      def http_client
        Faraday.new(request: { open_timeout: timeout, timeout: timeout }) do |faraday|
          faraday.adapter :typhoeus
        end
      end

      def build_request_body
        renderer = ERB.new(request_body_template)
        xml = renderer.result(binding)
        xml = xml.gsub(/^\s+/, '').gsub(/\s+$/, '').delete("\n")
        document = Xmldsig::SignedDocument.new(xml)
        document.sign do |data|
          digest = OpenSSL::Digest::SHA1.new
          OpenSSL::HMAC.digest(digest, hmac_secret, data)
        end.gsub("<?xml version=\"1.0\"?>\n", '')
      end

      def build_request_headers
        {
          'SOAPAction' => SOAP_ACTION,
          'Content-Type' => CONTENT_TYPE,
          'Content-Length' => body.length.to_s,
        }
      end

      def request_body_template
        template_file_path = File.join(
          File.dirname(__FILE__),
          'templates/authentication_token.xml.erb',
        )
        File.read(template_file_path)
      end

      def message_timestamp_uuid
        @message_timestamp_uuid ||= SecureRandom.uuid
      end

      def created_at
        @created_at ||= Time.now.utc
      end

      def expires_at
        created_at + 300
      end

      def uuid
        SecureRandom.uuid
      end

      def timeout
        ENV.fetch('AAMVA_AUTH_REQUEST_TIMEOUT', 5).to_i
      end
    end
  end
end
