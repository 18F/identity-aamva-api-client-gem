describe Aamva::Request::VerificationRequest do
  let(:applicant) do
    applicant = Aamva::Applicant.from_proofer_applicant(
      uuid: '1234-abcd-efgh',
      first_name: 'Bob',
      last_name: 'Ross',
      dob: '10/29/1942',
    )
    applicant.state_id_data.merge!(
      state_id_number: '123456789',
      state_id_jurisdiction: 'CA',
      state_id_type: 'drivers_license'
    )
    applicant
  end
  let(:auth_token) { 'KEYKEYKEY' }
  let(:transaction_id) { '1234-abcd-efgh' }

  subject do
    described_class.new(
      applicant: applicant,
      session_id: transaction_id,
      auth_token: auth_token
    )
  end

  describe '#body' do
    it 'should be a request body' do
      expect(subject.body).to eq(Fixtures.verification_request)
    end

    it 'should escape XML in applicant data' do
      applicant.first_name = '<foo></bar>'

      expect(subject.body).to_not include('<foo></bar>')
      expect(subject.body).to include('&lt;foo&gt;&lt;/bar&gt;')
    end
  end

  describe '#headers' do
    it 'should return valid SOAP headers' do
      expect(subject.headers).to eq(
        'SOAPAction' =>
          '"http://aamva.org/dldv/wsdl/2.1/IDLDVService21/VerifyDriverLicenseData"',
        'Content-Type' => 'application/soap+xml;charset=UTF-8',
        'Content-Length' => subject.body.length.to_s
      )
    end
  end

  describe '#url' do
    it 'should be the AAMVA verification url from the params' do
      expect(subject.url).to eq(
        Aamva::Request::VerificationRequest.verification_url
      )
    end
  end
end
