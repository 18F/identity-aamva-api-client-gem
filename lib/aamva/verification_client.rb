module Aamva
  class VerificationClient
    def send_verification_request(applicant:, session_id: nil)
      request = Request::VerificationRequest.new(
        applicant: applicant,
        session_id: session_id,
        auth_token: auth_token
      )
      Response::VerificationResponse.new(HTTPI.post(request))
    end

    private

    def auth_token
      @auth_token ||= AuthenticationClient.new.fetch_token
    end
  end
end
