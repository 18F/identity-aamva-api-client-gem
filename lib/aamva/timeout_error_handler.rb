module Aamva
  class TimeoutErrorHandler
    def initialize(http_response:, context:)
      @http_response = http_response
      @context = context
    end

    def call
      return unless http_response.timed_out?
      raise ::Proofer::TimeoutError, "AAMVA timed out waiting for #{context} response"
    end

    private

    attr_reader :http_response, :context
  end
end
