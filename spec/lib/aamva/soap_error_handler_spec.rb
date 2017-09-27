describe Aamva::SoapErrorHander do
  let(:response_body) { Fixtures.soap_fault_response }

  subject do
    http_response = HTTPI::Response.new(200, {}, response_body)
    described_class.new(http_response)
  end

  describe 'error_present?' do
    context 'when an error is present' do
      it { expect(subject.error_present?).to eq(true) }
    end

    context 'when an error is not present' do
      let(:response_body) { Fixtures.authentication_token_response }

      it { expect(subject.error_present?).to eq(false) }
    end
  end

  describe 'error_message' do
    context 'when there is no error' do
      let(:response_body) { Fixtures.authentication_token_response }

      it { expect(subject.error_message).to eq(nil) }
    end

    context 'when there is an error' do
      it { expect(subject.error_message).to eq('A FooBar error occurred') }
    end

    context 'when there is an error without a message' do
      let(:response_body) do
        delete_xml_at_xpath(
          Fixtures.soap_fault_response,
          '//s:Reason'
        )
      end

      it { expect(subject.error_message).to eq('A SOAP error occurred') }
    end
  end
end
