describe Proofer::Vendor::Aamva do
  let(:proofer_applicant) { Proofer::Applicant.new({}) }
  let(:aamva_applicant) do
    Aamva::Applicant.from_proofer_applicant(
      Proofer::Applicant.new(state_id_data)
    )
  end
  let(:aamva_response) { instance_double(Aamva::Response::VerificationResponse) }
  let(:verification_client) { Aamva::VerificationClient.new }
  let(:state_id_data) do
    {
      state_id_number: '1234567890',
      state_id_jurisdiction: 'VA',
      state_id_type: 'drivers_license',
    }
  end
  let(:session_id) { 'abc-123-efgh' }
  let(:success) { true }
  let(:verification_results) do
    {
      state_id_number: true,
      dob: true,
      last_name: true,
      last_name_fuzzy: true,
      last_name_fuzzy_alternative: true,
      first_name: true,
      first_name_fuzzy: true,
      first_name_fuzzy_alternative: true,
      address1: true,
      address2: true,
      city: true,
      state: true,
      zipcode: true,
    }
  end

  subject do
    described_class.new(applicant: proofer_applicant)
  end

  describe '#submit_state_id' do
    before do
      allow(Aamva::VerificationClient).to receive(:new).and_return(verification_client)
      allow(verification_client).to receive(:send_verification_request).with(
        applicant: aamva_applicant,
        session_id: session_id
      ).and_return(aamva_response)
      allow(aamva_response).to receive(:success?).and_return(success)
      allow(aamva_response).to receive(:verification_results).and_return(verification_results)
    end

    context 'when verification is successful' do
      it 'should return a successful confirmation' do
        response = subject.submit_state_id(state_id_data, session_id)

        expect(response).to be_a(Proofer::Confirmation)
        expect(response.success?).to eq(true)
        expect(response.vendor_resp).to eq(aamva_response)
        expect(response.errors).to eq({})
      end
    end

    context 'when verification is unsuccessful' do
      let(:success) { false }
      let(:verification_results) { super().merge(dob: false, zipcode: false) }

      it 'should return a failed confirmation' do
        response = subject.submit_state_id(state_id_data, session_id)

        expect(response).to be_a(Proofer::Confirmation)
        expect(response.success?).to eq(false)
        expect(response.vendor_resp).to eq(aamva_response)
        expect(response.errors).to eq(dob: 'UNVERIFIED', zipcode: 'UNVERIFIED')
      end
    end
  end
end
