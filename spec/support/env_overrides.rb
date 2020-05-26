require 'base64'

module EnvOverrides
  def self.set_test_environment_variables
    ENV['AAMVA_CERT_ENABLED'] = 'false'
    ENV['AAMVA_PRIVATE_KEY'] = Base64.strict_encode64 Fixtures.aamva_private_key.to_der
    ENV['AAMVA_PUBLIC_KEY'] = Base64.strict_encode64 Fixtures.aamva_public_key.to_der
    ENV['AAMVA_VERIFICATION_URL'] =
      'https://verificationservices-primary.example.com:18449/dldv/2.1/valuefree'
    ENV['AAMVA_AUTH_URL'] =
      'https://authentication-cert.example.com/Authentication/Authenticate.svc'
  end
end
