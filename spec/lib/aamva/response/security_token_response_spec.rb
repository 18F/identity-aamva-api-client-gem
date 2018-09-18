describe Aamva::Response::SecurityTokenResponse do
  let(:security_context_token_identifier) { 'sct-token-identifier' }
  let(:security_context_token_reference) { 'sct-token-reference' }
  let(:nonce) { 'MTExMTExMTExMTExMTExMTExMTExMTExMTExMTExMTE=' }

  let(:status_code) { 200 }
  let(:response_body) { Fixtures.security_token_response }
  let(:return_code) { :ok }
  let(:http_response) do
    Typhoeus::Response.new(code: status_code, body: response_body, return_code: return_code)
  end

  subject do
    described_class.new(http_response)
  end

  describe '#initialize' do
    context 'when the request timed out' do
      let(:return_code) { :operation_timedout }

      it 'raises a timeout error' do
        expect { subject }.to raise_error(
          Proofer::TimeoutError,
          'AAMVA timed out waiting for security token response'
        )
      end
    end

    context 'with a non-200 status code' do
      let(:status_code) { 500 }

      it 'raises an AuthenticationError' do
        expect { subject }.to raise_error(
          Aamva::AuthenticationError,
          'Unexpected status code in response: 500'
        )
      end
    end

    context 'when the API response is an error' do
      let(:response_body) { Fixtures.soap_fault_response_simplified }

      it 'raises an AuthenticationError' do
        expect { subject }.to raise_error(
          Aamva::AuthenticationError,
          'A FooBar error occurred'
        )
      end
    end

    context 'when the security context token is missing' do
      let(:response_body) { delete_xml_at_xpath(super(), '//c:SecurityContextToken') }

      it 'should raise an error' do
        expect { subject }.to raise_error(
          Aamva::AuthenticationError,
          'The authentication response is missing a security context token'
        )
      end
    end
  end

  describe '#security_context_token_identifier' do
    it 'returns the security token identifier from the request' do
      expect(subject.security_context_token_identifier).to eq(security_context_token_identifier)
    end
  end

  describe '#security_context_token_reference' do
    it 'returns the security context token reference from the request' do
      expect(subject.security_context_token_reference).to eq(security_context_token_reference)
    end
  end

  describe '#nonce' do
    it 'returns the nonce from the request' do
      expect(subject.nonce).to eq(subject.nonce)
    end
  end
end
