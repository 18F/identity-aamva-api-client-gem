# Using AAMVA proofing vendor for state ID

This is an implementation of the proofing vendor class described by the
[identity-proofer-gem](https://github.com/18F/identity-proofer-gem).

```ruby
applicant = Proofer::Applicant.new(
  first_name: 'Steve',
  last_name: 'Stevens',
  dob: '01/01/1995',
  address1: '123 Main St',
  address2: 'Apt 1',
  city: 'Baton Rouge',
  state: 'LA',
  zipcode: '70808'
)

proofer = Aamva::Proofer.new(
  private_key: 'base64privatekey',
  public_key: 'base64publickey',
  verification_url: 'https://verificationservices-primary.aamva.org:18449/dldv/2.1/valuefree',
  auth_url: 'https://authentication-cert.aamva.org/Authentication/Authenticate.svc'
)

response = proofer.submit_state_id(
  state_id_number: '123456789',
  state_id_jurisdiction: 'LA'
)

response.success? #=> True of false depending on proofing result
response.errors #=> Any errors that may have occurred
response.vendor_resp #=> An AAMVA::Response::VerificationResponse object
```

# Running the tests

### Unit tests

To run the unit tests, run `bundle exec rspec spec/lib/`.

### Integration tests

To run the integration tests:

- Download the file named "DLDV Structured Test Plan.xlsx" from Google Drive.
  Export it as a CSV and save the results
- Save the AAMVA public and private keys and set the `AAMVA_PRIVATE_KEY`, and
  `AAMVA_PUBLIC_KEY` appropriately in
  a `.env` file.
- Set `AAMVA_VERIFICATION_URL` to the AAMVA API url you wish to test in the
  `.env` file
- Set `AAMVA_AUTH_URL` to the auth url you wish to test in the `.env` file
- Set 'AAMVA_CERT_ENABLED' if you are using test data for the AAMVA cert environment
- Run `rspec spec/integration/`

