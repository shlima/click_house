RSpec.describe ClickHouse::Config do
  describe '#assign' do
    it 'works' do
      expect { subject.assign(port: 33) }.to change { subject.port }.to(33)
    end

    it 'returns self' do
      expect(subject.assign({})).to be_a(described_class)
    end
  end

  describe '#initialize' do
    context 'when params' do
      it 'works' do
        expect(described_class.new(port: 33).port).to eq(33)
      end
    end

    context 'when block' do
      it 'works' do
        expect(described_class.new { |c| c.port = 33 }.port).to eq(33)
      end
    end
  end

  describe '#auth?' do
    context 'when credentials empty' do
      before do
        subject.username = nil
        subject.password = nil
      end

      it 'is false' do
        expect(subject.auth?).to eq(false)
      end
    end

    context 'when credentials exists' do
      before do
        subject.username = 'foo'
        subject.password = 'bar'
      end

      it 'is true' do
        expect(subject.auth?).to eq(true)
      end
    end
  end

  describe '#url!' do
    before do
      subject.url = 'http://example.com'
      subject.scheme = 'https'
      subject.host = 'clickhouse'
      subject.port = '3344'
    end

    context 'when url exists' do
      it 'works' do
        expect(subject.url!).to eq('http://example.com')
      end
    end

    context 'when url empty' do
      before do
        subject.url = nil
      end

      it 'works' do
        expect(subject.url!).to eq('https://clickhouse:3344')
      end
    end
  end
end
