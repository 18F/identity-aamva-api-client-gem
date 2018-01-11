require 'base64'

module EnvOverrides
  def self.set_test_environment_variables
    ENV['AAMVA_PRIVATE_KEY'] = Base64.strict_encode64 Fixtures.aamva_private_key.to_der
    ENV['AAMVA_PUBLIC_KEY'] = Base64.strict_encode64 Fixtures.aamva_public_key.to_der
    ENV['AAMVA_VERIFICATION_URL'] =
      'https://verificationservices-primary.aamva.org:18449/dldv/2.1/valuefree'
    ENV['AUTH_URL'] =
      'https://authentication-cert.aamva.org/Authentication/Authenticate.svc'
  end
end
