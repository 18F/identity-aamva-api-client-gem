describe Aamva::Response::AuthenticationTokenResponse do
  let(:status_code) { 200 }
  let(:response_body) { Fixtures.authentication_token_response }
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
          'Timed out waiting for authentication token response'
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

    context 'when the API response has an error' do
      let(:response_body) { Fixtures.soap_fault_response_simplified }

      it 'raises an AuthenticationError' do
        expect { subject }.to raise_error(
          Aamva::AuthenticationError,
          'A FooBar error occurred'
        )
      end
    end

    context 'when the API response is missing a token' do
      let(:response_body) do
        delete_xml_at_xpath(
          Fixtures.authentication_token_response,
          '//Token'
        )
      end

      it 'raises an AuthenticationError' do
        expect { subject }.to raise_error(
          Aamva::AuthenticationError,
          'The authentication response is missing a token'
        )
      end
    end
  end

  describe '#auth_token' do
    it 'returns the token from the response body' do
      expect(subject.auth_token).to eq('KEYKEYKEY')
    end
  end
end
