require 'erb'
require 'faraday'
require 'openssl'
require 'securerandom'
require 'time'
require 'typhoeus/adapters/faraday'
require 'xmldsig'

module Aamva
  module Request
    class SecurityTokenRequest
      DEFAULT_AUTH_URL = 'https://authentication-cert.aamva.org/Authentication/Authenticate.svc'.freeze
      CONTENT_TYPE = 'application/soap+xml;charset=UTF-8'.freeze
      SOAP_ACTION =
        '"http://aamva.org/authentication/3.1.0/IAuthenticationService/Authenticate"'.freeze

      attr_reader :body, :headers, :url

      def initialize
        @body = build_request_body
        @headers = build_request_headers
        @url = SecurityTokenRequest.auth_url
      end

      def nonce
        @nonce ||= SecureRandom.base64(32)
      end

      def send
        Response::SecurityTokenResponse.new(
          http_client.post(url, body, headers)
        )
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => err
        message = "AAMVA raised #{err.class} waiting for security token response: #{err.message}"
        raise ::Proofer::TimeoutError, message
      end

      def self.auth_url
        Env.fetch('AAMVA_AUTH_URL', DEFAULT_AUTH_URL)
      end

      private

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
        document.sign(private_key).gsub("<?xml version=\"1.0\"?>\n", '')
      end

      def build_request_headers
        {
          'SOAPAction' => SOAP_ACTION,
          'Content-Type' => CONTENT_TYPE,
          'Content-Length' => body.length.to_s,
        }
      end

      def certificate
        @certificate = public_key.to_s.gsub(/\n?-----.+-----\n/, '')
      end

      def created_at
        @created_at ||= Time.now.utc
      end

      def expires_at
        created_at + 300
      end

      def key_identifier
        @key_identifier ||= begin
          digest = OpenSSL::Digest::SHA1.digest(public_key.to_der)
          Base64.encode64(digest)
        end.strip
      end

      def message_timestamp_uuid
        @message_timestamp_uuid ||= SecureRandom.uuid
      end

      def message_to_uuid
        @message_to_uuid ||= SecureRandom.uuid
      end

      def private_key
        @private_key ||= OpenSSL::PKey::RSA.new(
          Base64.decode64(Env.fetch('AAMVA_PRIVATE_KEY'))
        )
      end

      def public_key
        @public_key ||= OpenSSL::X509::Certificate.new(
          Base64.decode64(Env.fetch('AAMVA_PUBLIC_KEY'))
        )
      end

      def reply_to_uuid
        @reply_to_uuid ||= SecureRandom.uuid
      end

      def request_body_template
        template_file_path = File.join(
          File.dirname(__FILE__),
          'templates/security_token.xml.erb'
        )
        File.read(template_file_path)
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
