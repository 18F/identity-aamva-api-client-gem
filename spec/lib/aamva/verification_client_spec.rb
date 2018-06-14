describe Aamva::VerificationClient do
  let(:applicant) do
    applicant = Aamva::Applicant.from_proofer_applicant(
      Proofer::Applicant.new(
        uuid: '1234-4567-abcd-efgh',
        first_name: 'Bob',
        last_name: 'Ross',
        dob: '10/29/1942',
        address1: '123 Sunnyside way',
        address2: 'Box G',
        city: 'Sterling',
        state: 'VA',
        zipcode: '20176'
      )
    )
    applicant.state_id_data.merge!(
      state_id_number: '123456789',
      state_id_jurisdiction: 'CA',
      state_id_type: 'drivers_license'
    )
    applicant
  end

  describe '#send_verification_request' do
    it 'should get the auth token from the auth client' do
      auth_client = instance_double(Aamva::AuthenticationClient)
      allow(auth_client).to receive(:fetch_token).and_return('ThisIsTheToken')
      allow(Aamva::AuthenticationClient).to receive(:new).and_return(auth_client)

      verification_stub = stub_verification_request
      verification_stub.with do |request|
        xml_text_at_path(request.body, '//ns:token').gsub(/\s/, '') == 'ThisIsTheToken'
      end

      subject.send_verification_request(applicant: applicant, session_id: '1234-abcd-efgh')

      expect(verification_stub).to have_been_requested
    end

    context 'when verification is successful' do
      it 'should return a successful response' do
        auth_client = instance_double(Aamva::AuthenticationClient)
        allow(auth_client).to receive(:fetch_token).and_return('ThisIsTheToken')
        allow(Aamva::AuthenticationClient).to receive(:new).and_return(auth_client)
        stub_verification_request

        response = subject.send_verification_request(
          applicant: applicant,
          session_id: '1234-abcd-efgh'
        )

        expect(response).to be_a Aamva::Response::VerificationResponse
        expect(response.success?).to eq(true)
      end
    end

    context 'when verification is not successful' do
      it 'should return an unsuccessful response with errors' do
        auth_client = instance_double(Aamva::AuthenticationClient)
        allow(auth_client).to receive(:fetch_token).and_return('ThisIsTheToken')
        allow(Aamva::AuthenticationClient).to receive(:new).and_return(auth_client)

        verification_request = stub_verification_request
        verification_request.to_return(body: modify_xml_at_xpath(
          Fixtures.verification_response,
          '//PersonBirthDateMatchIndicator',
          'false'
        ))

        response = subject.send_verification_request(
          applicant: applicant,
          session_id: '1234-abcd-efgh'
        )

        expect(response).to be_a Aamva::Response::VerificationResponse
        expect(response.success?).to eq(true)
      end
    end
  end
end
