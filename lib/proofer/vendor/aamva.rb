require 'proofer/vendor/vendor_base'
require 'aamva'

module Proofer
  module Vendor
    class Aamva < VendorBase
      def submit_state_id(state_id_data, session_id = nil)
        read_state_id_data(state_id_data)
        aamva_applicant = ::Aamva::Applicant.from_proofer_applicant(applicant)
        response = verification_client.send_verification_request(
          applicant: aamva_applicant,
          session_id: session_id
        )
        process_response(response)
      end

      private

      def build_state_id_error(response)
        errors = {}
        response.verification_results.each do |attribute, result|
          errors[attribute] = 'UNVERIFIED' unless result == true
        end
        errors
      end

      def read_state_id_data(state_id_data)
        state_id_data.each do |param_name, param_value|
          applicant.instance_variable_set("@#{param_name}", param_value)
        end
      end

      def process_response(response)
        if response.success?
          successful_confirmation(response)
        else
          failed_confirmation(response, build_state_id_error(response))
        end
      end

      def verification_client
        @verification_client ||= ::Aamva::VerificationClient.new
      end
    end
  end
end
