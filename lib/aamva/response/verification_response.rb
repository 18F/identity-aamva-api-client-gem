require 'rexml/document'
require 'rexml/xpath'

module Aamva
  module Response
    class VerificationResponse
      VERIFICATION_ATTRIBUTES_MAP = {
        'DriverLicenseNumberMatchIndicator' => :state_id_number,
        'DocumentCategoryMatchIndicator' => :state_id_type,
        'PersonBirthDateMatchIndicator' => :dob,
        'PersonLastNameExactMatchIndicator' => :last_name,
        'PersonFirstNameExactMatchIndicator' => :first_name,
        'AddressLine1MatchIndicator' => :address1,
        'AddressCityMatchIndicator' => :city,
        'AddressStateCodeMatchIndicator' => :state,
        'AddressZIP5MatchIndicator' => :zipcode,
      }.freeze

      REQUIRED_VERIFICATION_ATTRIBUTES = %i[
        state_id_number
        state_id_type
        dob
        last_name
        first_name
        address1
        city
        state
        zipcode
      ].freeze

      attr_reader :verification_results

      def initialize(http_response)
        @missing_attributes = []
        @verification_results = {}
        @http_response = http_response
        handle_soap_error
        handle_http_error
        parse_response
        handle_missing_attributes_error
      end

      def reasons
        REQUIRED_VERIFICATION_ATTRIBUTES.map do |verification_attribute|
          next if verification_results[verification_attribute]
          "Failed to verify #{verification_attribute}"
        end.compact
      end

      def success?
        REQUIRED_VERIFICATION_ATTRIBUTES.each do |verification_attribute|
          return false unless verification_results[verification_attribute]
        end
        true
      end

      private

      attr_reader :http_response, :missing_attributes

      def handle_http_error
        status = http_response.code
        return if status == 200
        raise VerificationError, "Unexpected status code in response: #{status}"
      end

      def handle_missing_attributes_error
        return if missing_attributes.empty?
        missing_attribute_names = missing_attributes.join(', ')
        raise VerificationError, "Response is missing attributes: #{missing_attribute_names}"
      end

      def handle_soap_error
        error_handler = SoapErrorHander.new(http_response)
        return unless error_handler.error_present?
        raise VerificationError, error_handler.error_message
      end

      def node_for_match_indicator(match_indicator_name)
        REXML::XPath.first(rexml_document, "//#{match_indicator_name}")
      end

      def parse_response
        VERIFICATION_ATTRIBUTES_MAP.each_pair do |match_indicator_name, attribute_name|
          attribute_node = node_for_match_indicator(match_indicator_name)
          if attribute_node.nil?
            missing_attributes.push(attribute_name)
          elsif attribute_node.text == 'true'
            verification_results[attribute_name] = true
          else
            verification_results[attribute_name] = false
          end
        end
      end

      def rexml_document
        @rexml_document ||= REXML::Document.new(http_response.body)
      end
    end
  end
end
