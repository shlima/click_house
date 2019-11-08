RSpec.describe ClickHouse::Extend::ConnectionHealthy do
  subject do
    ClickHouse::Connection.new(ClickHouse.config)
  end

  describe '#ping' do
    context 'when ok' do
      it 'works' do
        expect(subject.ping).to eq(true)
      end
    end

    context 'when fail' do
      before do
        subject.transport.port = '80'
      end

      it 'errors' do
        expect { subject.ping }.to raise_error(ClickHouse::NetworkException)
      end
    end
  end

  describe '#replicas_status' do
    context 'when ok' do
      it 'works' do
        expect(subject.replicas_status).to eq(true)
      end
    end

    context 'when fail' do
      before do
        subject.transport.port = '80'
      end

      it 'errors' do
        expect { subject.replicas_status }.to raise_error(ClickHouse::NetworkException)
      end
    end
  end
end
