describe Aamva::Request::AuthenticationTokenRequest do
  let(:security_context_token_identifier) { 'sct-token-identifier' }
  let(:security_context_token_reference) { 'sct-token-reference' }
  let(:client_hmac_secret) { 'MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA=' }
  let(:server_hmac_secret) { 'MTExMTExMTExMTExMTExMTExMTExMTExMTExMTExMTE=' }

  subject do
    described_class.new(
      security_context_token_identifier: security_context_token_identifier,
      security_context_token_reference: security_context_token_reference,
      client_hmac_secret: client_hmac_secret,
      server_hmac_secret: server_hmac_secret
    )
  end

  before do
    allow(Time).to receive(:now).and_return(Time.utc(2017))
    allow(SecureRandom).to receive(:uuid).
      at_least(:once).
      and_return('12345678-abcd-efgh-ijkl-1234567890ab')
  end

  describe '#body' do
    it 'should be a signed request body' do
      expect(subject.body).to eq(Fixtures.authentication_token_request)
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
        URI.parse('https://authentication-cert.aamva.org/Authentication/Authenticate.svc')
      )
    end
  end
end
