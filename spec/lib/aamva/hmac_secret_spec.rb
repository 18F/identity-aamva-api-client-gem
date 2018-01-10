describe Aamva::HmacSecret do
  let(:client_secret) { 'MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA=' }
  let(:server_secret) { 'MTExMTExMTExMTExMTExMTExMTExMTExMTExMTExMTE=' }
  let(:expected_result) { Base64.strict_decode64 'txJiPvOByVADlND/OgUqlJFKoZlR3GPfxGSWMmrRzEM=' }

  describe '#base64digest' do
    it 'should return a decoded PSHA1 hash' do
      digest = Aamva::HmacSecret.new(client_secret, server_secret).psha1
      expect(digest).to eq(expected_result)
    end
  end
end
