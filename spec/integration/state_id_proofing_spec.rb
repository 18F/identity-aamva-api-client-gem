require 'csv'

describe 'State ID proofing' do
  before do
    Dotenv.load.each do |key, value|
      ENV[key] = value
    end
    WebMock.allow_net_connect!
  end

  after do
    EnvOverrides.set_test_environment_variables
    WebMock.disable_net_connect!
  end

  CSV.parse(Fixtures.aamva_test_data, headers: true).each do |row|
    it "should proof for row #{row['#']}" do
      applicant = Proofer::Applicant.new(applicant_data(row))

      agent = Proofer::Agent.new(vendor: :aamva, applicant: applicant)

      if row['MVA Timeout'] == 'TRUE'
        expect { agent.submit_state_id(state_id_data(row)) }.to raise_error(
          Aamva::VerificationError,
          'DLDV VSS'
        )
      else
        response = agent.submit_state_id(state_id_data(row))
        expect(response.success?).to eq(true)
      end
    end
  end

  def applicant_data(row)
    {
      uuid: SecureRandom.uuid,
      first_name: row['First Name'],
      last_name: row['Last Name'],
      dob: row['DOB (YYYYMMDD)'],
    }.merge(address_data(row))
  end

  def address_data(row)
    address_elements = (row['Resident address'] || row['Mailing address']).split('@')
    {
      address1: address_elements[0],
      address2: address_elements[1],
      city: address_elements[2],
      state: address_elements[3],
      zipcode: address_elements[4],
    }
  end

  def state_id_data(row)
    {
      state_id_number: row['Document #'],
      state_id_jurisdiction: address_data(row)[:state],
      state_id_type: state_id_type_from_category(row['Document Type']),
    }
  end

  def state_id_type_from_category(category)
    case category
    when '1'
      'drivers_license'
    when '2'
      'drivers_permit'
    when '3'
      'state_id_card'
    end
  end
end
