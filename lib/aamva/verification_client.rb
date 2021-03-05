module Aamva
  class VerificationClient
    attr_reader :config

    # @param [Aamva::Proofer::Config] config
    def initialize(config)
      @config = config
    end

    def send_verification_request(applicant:, session_id: nil)
      Request::VerificationRequest.new(
        applicant: applicant,
        session_id: session_id,
        auth_token: auth_token,
        config: config,
      ).send
    end

    private

    def auth_token
      @auth_token ||= AuthenticationClient.new.fetch_token(config)
    end
  end
end
