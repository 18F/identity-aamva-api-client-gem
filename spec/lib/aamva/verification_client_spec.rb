describe Aamva::VerificationClient do
  let(:applicant) do
    applicant = Aamva::Applicant.from_proofer_applicant(
      uuid: '1234-4567-abcd-efgh',
      first_name: 'Testy',
      last_name: 'McTesterson',
      dob: '10/29/1942'
    )
    applicant.state_id_data.merge!(
      state_id_number: '123456789',
      state_id_jurisdiction: 'CA',
      state_id_type: 'drivers_license'
    )
    applicant
  end

  subject(:verification_client) { described_class.new(example_config) }

  describe '#send_verification_request' do
    it 'should get the auth token from the auth client' do
      auth_client = instance_double(Aamva::AuthenticationClient)
      allow(auth_client).to receive(:fetch_token).and_return('ThisIsTheToken')
      allow(Aamva::AuthenticationClient).to receive(:new).and_return(auth_client)

      verification_stub = stub_request(:post, example_config.verification_url).
        to_return(body: Fixtures.verification_response, status: 200).
        with do |request|
          xml_text_at_path(request.body, '//ns:token').gsub(/\s/, '') == 'ThisIsTheToken'
        end

      verification_client.send_verification_request(applicant: applicant, session_id: '1234-abcd-efgh')

      expect(verification_stub).to have_been_requested
    end

    context 'when verification is successful' do
      it 'should return a successful response' do
        auth_client = instance_double(Aamva::AuthenticationClient)
        allow(auth_client).to receive(:fetch_token).and_return('ThisIsTheToken')
        allow(Aamva::AuthenticationClient).to receive(:new).and_return(auth_client)
        stub_request(:post, example_config.verification_url).
          to_return(body: Fixtures.verification_response, status: 200)

        response = verification_client.send_verification_request(
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

        stub_request(:post, example_config.verification_url).
          to_return(status: 200, body: modify_xml_at_xpath(
            Fixtures.verification_response,
            '//PersonBirthDateMatchIndicator',
            'false'
          ))

        response = verification_client.send_verification_request(
          applicant: applicant,
          session_id: '1234-abcd-efgh'
        )

        expect(response).to be_a Aamva::Response::VerificationResponse
        expect(response.success?).to eq(false)
      end
    end
  end
end
