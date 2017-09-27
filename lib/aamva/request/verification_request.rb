require 'erb'
require 'httpi'
require 'securerandom'

module Aamva
  module Request
    class VerificationRequest < HTTPI::Request
      CONTENT_TYPE = 'application/soap+xml;charset=UTF-8'.freeze
      DEFAULT_VERIFICATION_URL =
        'https://verificationservices-cert.aamva.org:18449/dldv/2.1/online'.freeze
      SOAP_ACTION = '"http://aamva.org/dldv/wsdl/2.1/IDLDVService21/VerifyDriverLicenseData"'.freeze

      extend Forwardable
      def_delegators :applicant, :first_name, :last_name, :dob, :state_id_data, :address

      def initialize(applicant:, session_id:, auth_token:)
        @applicant = applicant
        @transaction_id = session_id
        @auth_token = auth_token
        self.url = VerificationRequest.verification_url
        self.body = build_request_body
        self.headers = build_request_headers
      end

      def self.verification_url
        ENV.fetch('AAMVA_VERIFICATION_URL', DEFAULT_VERIFICATION_URL)
      end

      private

      attr_reader :applicant, :transaction_id, :auth_token

      def build_request_body
        renderer = ERB.new(request_body_template)
        renderer.result(binding).gsub(/^\s+/, '').gsub(/\s+$/, '').delete("\n")
      end

      def build_request_headers
        {
          'SOAPAction' => SOAP_ACTION,
          'Content-Type' => CONTENT_TYPE,
          'Content-Length' => body.length.to_s,
        }
      end

      def document_category_code
        case state_id_data.state_id_type
        when 'drivers_license'
          1
        when 'drivers_permit'
          2
        when 'state_id_card'
          3
        end
      end

      def message_destination_id
        'P6' # TODO State or test destination
      end

      def request_body_template
        template_file_path = File.join(
          File.dirname(__FILE__),
          'templates/verify.xml.erb'
        )
        File.read(template_file_path)
      end

      def transaction_locator_id
        applicant.uuid
      end

      def uuid
        SecureRandom.uuid
      end
    end
  end
end
