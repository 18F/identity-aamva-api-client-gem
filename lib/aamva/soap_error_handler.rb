require 'rexml/document'
require 'rexml/xpath'

module Aamva
  class SoapErrorHander
    attr_reader :error_message, :http_response

    def initialize(http_response)
      @http_response = http_response
      parse_response
    end

    def error_present?
      @error_present
    end

    private

    def parse_response
      document = REXML::Document.new(@http_response.body)
      @error_present = !REXML::XPath.first(document, '//s:Fault').nil?
      return unless error_present?
      reason_node = REXML::XPath.first(document, '//s:Reason/s:Text')
      @error_message = reason_node&.text || 'A SOAP error occurred'
    end
  end
end
