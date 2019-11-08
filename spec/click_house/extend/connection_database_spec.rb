RSpec.describe ClickHouse::Extend::ConnectionDatabase do
  subject do
    ClickHouse.connection
  end

  describe '#databases' do
    it 'works' do
      expect(subject.databases).to include('default', 'system', ClickHouse.config.database)
    end
  end

  describe '#create_database' do
    context 'when exists' do
      it 'errors' do
        expect { subject.create_database(ClickHouse.config.database) }.to raise_error(ClickHouse::DbException)
      end
    end

    context 'when if not exists' do
      it 'works' do
        expect(subject.create_database(ClickHouse.config.database, if_not_exists: true)).to eq(true)
      end
    end

    context 'when default' do
      it 'works' do
        expect(subject.create_database('foo')).to eq(true)
      end
    end

    context 'when engine' do
      it 'works' do
        expect(subject.create_database('foo', engine: 'Lazy(10)')).to eq(true)
      end
    end
  end

  describe '#drop_database' do
    context 'when not exists' do
      it 'errors' do
        expect { subject.drop_database('foo') }.to raise_error(ClickHouse::DbException)
      end
    end

    context 'when exists' do
      it 'works' do
        expect(subject.drop_database('foo', if_exists: true)).to eq(true)
      end
    end
  end
end
