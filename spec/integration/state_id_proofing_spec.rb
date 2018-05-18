require 'csv'
require 'set'

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
      response = Aamva::Proofer.new.proof(applicant_data(row))

      if row['Result'] == 'VERIFIED'
        expect(response.success?).to eq(true)
      elsif row['Result'] == 'UNVERIFIED'
        expect(response.success?).to eq(false)
        expect(response.failed?).to eq(true)
        error_attributes = response.errors.keys.map(&:to_s)
        expected_error_attributes = row['Unverified Attrs'].split(',')
        expect(Set.new(error_attributes)).to eq(Set.new(expected_error_attributes))
      elsif row['Result'] == 'ERROR'
        expect(response.success?).to eq(false)
        expect(response.failed?).to eq(false)
        expect(response.exception?).to eq(true)
        expect(response.exception).to be_a(RuntimeError)
        expect(response.exception.message).to include('Required attributes first_name, last_name, dob, state_id_number are not present')
      else
        raise "Unknown result type: #{row['Result']}"
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
    .merge(state_id_data(row))
  end

  def address_data(row)
    address_elements = row['Address'].split('@')
    {
      address1: address_elements[0],
      # address2: address_elements[1],
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
