RSpec.describe ClickHouse::Type::IPType do
  describe '#cast' do
    let(:ip) do
      IPAddr.new('127.0.0.1')
    end

    it 'works' do
      expect(subject.cast(String(ip))).to eq(ip)
    end
  end

  describe '#serialize' do
    let(:ip) do
      IPAddr.new('127.0.0.1')
    end

    it 'works' do
      expect(subject.serialize(ip)).to eq('127.0.0.1')
    end
  end
end
