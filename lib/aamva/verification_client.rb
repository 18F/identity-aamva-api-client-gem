module Aamva
  class VerificationClient
    def send_verification_request(applicant:, session_id: nil)
      Request::VerificationRequest.new(
        applicant: applicant,
        session_id: session_id,
        auth_token: auth_token
      ).send
    end

    private

    def auth_token
      @auth_token ||= AuthenticationClient.new.fetch_token
    end
  end
end
