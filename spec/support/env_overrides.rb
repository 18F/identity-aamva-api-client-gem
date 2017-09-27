module EnvOverrides
  def self.set_test_environment_variables
    ENV['AAMVA_PRIVATE_KEY_PATH'] = File.join(
      File.dirname(__FILE__),
      '../fixtures/keys/aamva-private-key.example.pem'
    )
    ENV['AAMVA_PUBLIC_KEY_PATH'] = File.join(
      File.dirname(__FILE__),
      '../fixtures/keys/aamva-public-key.example.crt'
    )
    ENV['AAMVA_PRIVATE_KEY_PASSPHRASE'] = 'sekret'
    ENV['AAMVA_VERIFICATION_URL'] =
      'https://verificationservices-primary.aamva.org:18449/dldv/2.1/valuefree'
  end
end
