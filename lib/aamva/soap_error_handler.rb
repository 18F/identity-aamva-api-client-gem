require 'rexml/document'
require 'rexml/xpath'

module Aamva
  class SoapErrorHander
    attr_reader :error_message

    def initialize(http_response)
      @document = REXML::Document.new(http_response.body)
      parse_error_message
    end

    def error_present?
      @error_present
    end

    private

    attr_reader :document

    def parse_error_message
      @error_present = !soap_fault_node.nil?
      return unless error_present?
      @error_message = soap_error_reason_text_node&.text || 'A SOAP error occurred'
    end

    def soap_error_reason_text_node
      REXML::XPath.first(
        document,
        '//soap-envelope:Reason/soap-envelope:Text',
        'soap-envelope' => 'http://www.w3.org/2003/05/soap-envelope'
      )
    end

    def soap_fault_node
      REXML::XPath.first(
        document,
        '//soap-envelope:Fault',
        'soap-envelope' => 'http://www.w3.org/2003/05/soap-envelope'
      )
    end
  end
end
