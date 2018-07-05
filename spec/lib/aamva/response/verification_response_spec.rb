require 'rexml/document'
require 'rexml/xpath'

describe Aamva::Response::VerificationResponse do
  let(:status_code) { 200 }
  let(:response_body) { Fixtures.verification_response }
  let(:http_response) { HTTPI::Response.new(status_code, {}, response_body) }
  let(:verification_results) do
    {
      state_id_number: true,
      state_id_type: true,
      dob: true,
      last_name: true,
      first_name: true,
    }
  end

  subject do
    described_class.new(http_response)
  end

  describe '#initialize' do
    context 'with a non-200 status code' do
      let(:status_code) { 500 }

      it 'raises a VerificationError' do
        expect { subject }.to raise_error(
          Aamva::VerificationError,
          'Unexpected status code in response: 500'
        )
      end
    end

    context 'when the API response has an error' do
      let(:response_body) { Fixtures.soap_fault_response_simplified }

      it 'raises a VerificationError' do
        expect { subject }.to raise_error(
          Aamva::VerificationError,
          'A FooBar error occurred'
        )
      end
    end
  end

  describe '#reasons' do
    context 'when all attiutes are verified' do
      it 'returns an empty array' do
        expect(subject.reasons).to eq([])
      end
    end

    context 'when required attributes are verified' do
      let(:response_body) do
        modify_match_indicator(
          Fixtures.verification_response,
          'PersonLastNameFuzzyPrimaryMatchIndicator',
          'false'
        )
      end

      it 'returns an empty array' do
        expect(subject.reasons).to eq([])
      end
    end

    context 'when required attributes are not verified' do
      let(:response_body) do
        body = modify_match_indicator(
          Fixtures.verification_response,
          'PersonBirthDateMatchIndicator',
          'false'
        )
        delete_match_indicator(
          body,
          'PersonFirstNameExactMatchIndicator'
        )
      end

      it 'returns an array with the reasons verifiation failed' do
        expect(subject.reasons).to eq(['Failed to verify dob', 'Response was missing first_name'])
      end
    end
  end

  describe '#success?' do
    context 'when all attributes are verified' do
      it { expect(subject.success?).to eq(true) }
    end

    context 'when required attributes are verified' do
      let(:response_body) do
        modify_match_indicator(
          Fixtures.verification_response,
          'PersonLastNameFuzzyPrimaryMatchIndicator',
          'false'
        )
      end

      it { expect(subject.success?).to eq(true) }
    end

    context 'when required attributes are not verified' do
      let(:response_body) do
        modify_match_indicator(
          Fixtures.verification_response,
          'PersonBirthDateMatchIndicator',
          'false'
        )
      end

      it { expect(subject.success?).to eq(false) }
    end

    context 'when required attributes are missing' do
      let(:response_body) do
        delete_match_indicator(
          Fixtures.verification_response,
          'PersonBirthDateMatchIndicator'
        )
      end

      it { expect(subject.success?).to eq(false) }
    end
  end

  describe '#verification_results' do
    context 'when all attributes are verified' do
      it 'returns a hash of values that were verified' do
        expect(subject.verification_results).to eq(verification_results)
      end
    end

    context 'when not all attributes are verified' do
      let(:response_body) do
        body = modify_match_indicator(
          Fixtures.verification_response,
          'PersonBirthDateMatchIndicator',
          'false'
        )
        delete_match_indicator(
          body,
          'PersonFirstNameExactMatchIndicator'
        )
      end

      it 'returns a hash of values that were verified and values that were not' do
        expected_result = verification_results.merge(dob: false, first_name: nil)

        expect(subject.verification_results).to eq(expected_result)
      end
    end
  end

  def modify_match_indicator(xml, name, value)
    modify_xml_at_xpath(xml, "//#{name}", value)
  end

  def delete_match_indicator(xml, name)
    delete_xml_at_xpath(xml, "//#{name}")
  end
end
