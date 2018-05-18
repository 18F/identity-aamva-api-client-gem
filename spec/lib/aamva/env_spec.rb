describe Aamva::Env do
  describe '.fetch' do
    let(:all_caps) { 'ALL_CAPS' }
    let(:all_lower) { 'all_lower' }
    let(:env) { { all_caps => 'captivating', all_lower => 'lowdown' } }
    let(:no_exist) { 'no_exist' }

    before do
      ENV[all_caps] = env[all_caps]
      ENV[all_lower] = env[all_lower]
    end

    context 'without a default' do
      it 'returns the value when the key is present' do
        expect(described_class.fetch(all_caps)).to eq(env[all_caps])
      end

      it 'returns the value when the downcased key is present' do
        expect(described_class.fetch(all_lower.upcase)).to eq(env[all_lower])
      end

      it 'raises when the value is not present' do
        expect { described_class.fetch(no_exist) }.to raise_error(KeyError)
      end
    end

    context 'with a default' do
      let(:default) { 'default' }

      it 'returns the value when they key is present' do
        expect(described_class.fetch(all_caps, default)).to eq(env[all_caps])
      end

      it 'returns the value when the downcased key is present' do
        expect(described_class.fetch(all_lower.upcase, default)).to eq(env[all_lower])
      end

      it 'returns the default when the value is not present' do
        expect(described_class.fetch(no_exist, default)).to eq(default)
      end
    end
  end
end
