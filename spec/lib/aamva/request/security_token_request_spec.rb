require 'rexml/document'
require 'rexml/xpath'

describe Aamva::Request::SecurityTokenRequest do
  before do
    allow(Time).to receive(:now).and_return(Time.utc(2017))
    allow(SecureRandom).to receive(:base64).
      with(32).
      and_return('MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA=')
    allow(SecureRandom).to receive(:uuid).
      at_least(:once).
      and_return('12345678-abcd-efgh-ijkl-1234567890ab')
  end

  describe '#body' do
    it 'should be a signed request body' do
      document = REXML::Document.new(subject.body)
      public_key = REXML::XPath.first(document, '//wsse:BinarySecurityToken')
      signature = REXML::XPath.first(document, '//ds:SignatureValue')
      key_identifier = REXML::XPath.first(document, '//wsse:KeyIdentifier')

      expect(public_key.text).to eq Base64.strict_encode64(Fixtures.aamva_public_key.to_der)
      expect(key_identifier.text).to_not be_nil
      expect(key_identifier.text).to_not be_empty
      expect(signature.text).to_not be_nil
      expect(signature.text).to_not be_empty

      body_without_sig = subject.body.
                         gsub(public_key.text, '').
                         gsub(signature.text, '').
                         gsub(key_identifier.text, '')

      expect(body_without_sig).to eq(Fixtures.security_token_request)
    end
  end

  describe '#headers' do
    it 'should return valid SOAP headers' do
      expect(subject.headers).to eq(
        'SOAPAction' =>
          '"http://aamva.org/authentication/3.1.0/IAuthenticationService/Authenticate"',
        'Content-Type' => 'application/soap+xml;charset=UTF-8',
        'Content-Length' => subject.body.length.to_s
      )
    end
  end

  describe '#url' do
    it 'should be the AAMVA authentication url' do
      expect(subject.url).to eq(
        'https://authentication-cert.aamva.org/Authentication/Authenticate.svc'
      )
    end
  end

  describe '#send' do
    context 'when the request is successful' do
      it 'returns a response object' do
        connection = instance_double(Faraday::Connection)
        faraday_response = instance_double(Faraday::Response)
        response = instance_double(Aamva::Response::SecurityTokenResponse)

        expect(Faraday).to receive(:new).and_return(connection)
        expect(connection).to receive(:post).and_return(faraday_response)
        expect(Aamva::Response::SecurityTokenResponse).to receive(:new).
          with(faraday_response).
          and_return(response)

        result = subject.send

        expect(result).to eq(response)
      end
    end

    context 'when the request times out' do
      it 'raises an error' do
        connection = instance_double(Faraday::Connection)

        expect(Faraday).to receive(:new).and_return(connection)
        expect(connection).to receive(:post).and_raise(Faraday::TimeoutError.new)

        expect { subject.send }.to raise_error(
          ::Proofer::TimeoutError,
          'AAMVA raised Faraday::TimeoutError waiting for security token response',
        )
      end
    end

    context 'when the connection fails' do
      it 'raises an error' do
        connection = instance_double(Faraday::Connection)

        expect(Faraday).to receive(:new).and_return(connection)
        expect(connection).to receive(:post).and_raise(Faraday::ConnectionFailed.new('error'))

        expect { subject.send }.to raise_error(
          ::Proofer::TimeoutError,
          'AAMVA raised Faraday::ConnectionFailed waiting for security token response',
        )
      end
    end
  end
end
