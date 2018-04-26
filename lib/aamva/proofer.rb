require 'ostruct'

module Aamva
  class Proofer < Proofer::Base
    attributes :uuid,
               :first_name,
               :last_name,
               :dob,
               :address1,
               :address2,
               :city,
               :state,
               :zipcode,
               :state_id_number,
               :state_id_type

    stage :state_id

    proof do |applicant, result|
      aamva_proof(applicant, result)
    end

    def aamva_proof(applicant, result)
      aamva_applicant = Aamva::Applicant.from_proofer_applicant(OpenStruct.new(applicant))
      response = Aamva::VerificationClient.new.send_verification_request(applicant: aamva_applicant)
      unless response.success?
        response.verification_results.each do |attribute, v_result|
          result.add_error("#{attribute}: UNVERIFIED") if v_result == false
          result.add_error("#{attribute}: MISSING") if v_result.nil?
        end
      end
    end
  end
end
