require 'erb'
require 'rexml/document'
require 'rexml/xpath'
require 'securerandom'
require 'typhoeus'

module Aamva
  module Request
    class VerificationRequest
      CONTENT_TYPE = 'application/soap+xml;charset=UTF-8'.freeze
      DEFAULT_VERIFICATION_URL =
        'https://verificationservices-cert.aamva.org:18449/dldv/2.1/online'.freeze
      SOAP_ACTION = '"http://aamva.org/dldv/wsdl/2.1/IDLDVService21/VerifyDriverLicenseData"'.freeze

      extend Forwardable

      attr_reader :body, :headers, :url

      def initialize(applicant:, session_id:, auth_token:)
        @applicant = applicant
        @transaction_id = session_id
        @auth_token = auth_token
        @url = VerificationRequest.verification_url
        @body = build_request_body
        @headers = build_request_headers
      end

      def send
        Response::VerificationResponse.new(
          Typhoeus.post(url, body: body, headers: headers, timeout: timeout)
        )
      end

      def self.verification_url
        Env.fetch('AAMVA_VERIFICATION_URL', DEFAULT_VERIFICATION_URL)
      end

      private

      attr_reader :applicant, :transaction_id, :auth_token

      def add_user_provided_data_to_body
        document = REXML::Document.new(body)
        user_provided_data_map.each do |xpath, data|
          REXML::XPath.first(document, xpath).add_text(data)
        end
        @body = document.to_s
      end

      def build_request_body
        renderer = ERB.new(request_body_template)
        @body = renderer.result(binding)
        add_user_provided_data_to_body
      end

      def build_request_headers
        {
          'SOAPAction' => SOAP_ACTION,
          'Content-Type' => CONTENT_TYPE,
          'Content-Length' => body.length.to_s,
        }
      end

      def document_category_code
        case applicant.state_id_data.state_id_type
        when 'drivers_license'
          '1'
        when 'drivers_permit'
          '2'
        when 'state_id_card'
          '3'
        end
      end

      def message_destination_id
        return 'P6' if Env.fetch('AAMVA_CERT_ENABLED') == 'true'
        applicant.state_id_data.state_id_jurisdiction
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

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def user_provided_data_map
        applicant_address = applicant.address
        {
          '//ns2:IdentificationID' => applicant.state_id_data.state_id_number,
          '//ns1:DocumentCategoryCode' => document_category_code,
          '//ns1:MessageDestinationId' => message_destination_id,
          '//ns2:PersonGivenName' => applicant.first_name,
          '//ns2:PersonSurName' => applicant.last_name,
          '//ns1:PersonBirthDate' => applicant.dob,
        }
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def uuid
        SecureRandom.uuid
      end

      def timeout
        ENV.fetch('AAMVA_VERIFICATION_REQUEST_TIMEOUT', 5).to_i
      end
    end
  end
end
