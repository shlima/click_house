RSpec.describe ClickHouse::Middleware::Logging do
  subject do
    ClickHouse::Connection.new(ClickHouse.config.clone.assign(logger: logger))
  end

  let(:out) do
    StringIO.new
  end

  let(:logger) do
    Logger.new(out)
  end

  context 'when POST' do
    it 'works' do
      subject.execute('SELECT 1')
      expect(out.string).to match(/Total: \d/)
      expect(out.string).to include('SELECT 1;')
      expect(out.string).to include('Read: 1 rows')
      expect(out.string).to include('Written: 0 rows')
    end
  end

  context 'when GET' do
    it 'works' do
      subject.select_all('SELECT 1')
      expect(out.string).to match(/Total: \d/)
      expect(out.string).to include('SELECT 1;')
      expect(out.string).to include('Read: 1 rows')
      expect(out.string).to include('Written: 0 rows')
    end
  end
end
