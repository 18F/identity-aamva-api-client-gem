describe Aamva::Applicant do
  let(:proofer_applicant) do
    {
      uuid: '1234-4567-abcd-efgh',
      first_name: 'Bob',
      last_name: 'Ross',
      dob: '10/29/1942',
      state_id_number: '123456789',
      state_id_jurisdiction: 'VA',
      state_id_type: 'drivers_license',
    }
  end

  describe '.from_proofer_applicant(applicant)' do
    it 'should create an AAMVA applicant with necessary proofer applcant data' do
      aamva_applicant = described_class.from_proofer_applicant(proofer_applicant)

      expect(aamva_applicant.uuid).to eq(proofer_applicant[:uuid])
      expect(aamva_applicant.first_name).to eq(proofer_applicant[:first_name])
      expect(aamva_applicant.last_name).to eq(proofer_applicant[:last_name])
      expect(aamva_applicant.dob).to eq('1942-10-29')
      expect(aamva_applicant.state_id_data.state_id_number).to eq(
        proofer_applicant[:state_id_number]
      )
      expect(aamva_applicant.state_id_data.state_id_jurisdiction).to eq(
        proofer_applicant[:state_id_jurisdiction]
      )
      expect(aamva_applicant.state_id_data.state_id_type).to eq(proofer_applicant[:state_id_type])
    end
  end

  it 'should format dob into CCYY-MM-DD form' do
    proofer_applicant[:dob] = '1942-10-29'
    aamva_applicant = Aamva::Applicant.from_proofer_applicant(proofer_applicant)

    expect(aamva_applicant.dob).to eq('1942-10-29')

    proofer_applicant[:dob] = '10/29/1942'
    aamva_applicant = Aamva::Applicant.from_proofer_applicant(proofer_applicant)

    expect(aamva_applicant[:dob]).to eq('1942-10-29')

    proofer_applicant[:dob] = '19421029'
    aamva_applicant = Aamva::Applicant.from_proofer_applicant(proofer_applicant)

    expect(aamva_applicant[:dob]).to eq('1942-10-29')
  end

  it 'should format empty or malformed dobs into empty strings' do
    proofer_applicant[:dob] = ''
    aamva_applicant = Aamva::Applicant.from_proofer_applicant(proofer_applicant)

    expect(aamva_applicant.dob).to eq('')

    proofer_applicant[:dob] = nil
    aamva_applicant = Aamva::Applicant.from_proofer_applicant(proofer_applicant)

    expect(aamva_applicant[:dob]).to eq('')

    proofer_applicant[:dob] = '10/29/19422'
    aamva_applicant = Aamva::Applicant.from_proofer_applicant(proofer_applicant)

    expect(aamva_applicant[:dob]).to eq('')
  end
end
