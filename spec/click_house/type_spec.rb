RSpec.describe ClickHouse::Type do
  subject do
    ClickHouse.connection
  end

  context 'when extendable (one arg)' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec(time DateTime('Europe/Moscow')) ENGINE TinyLog
      SQL

      subject.execute <<~SQL
        INSERT INTO rspec VALUES ('2019-01-01 10:00 AM')
      SQL
    end

    it 'works' do
      subject.execute('SELECT * FROM rspec FORMAT JSON')
      expect(subject.select_value('SELECT * FROM rspec')).to be_a(DateTime)
    end
  end

  context 'when extendable (two arg)' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec(lat Decimal(5, 5)) ENGINE TinyLog
      SQL

      subject.execute <<~SQL
        INSERT INTO rspec VALUES (0.1234)
      SQL
    end

    it 'works' do
      expect(subject.select_value('SELECT * FROM rspec')).to eq(BigDecimal(0.1234, 5))
    end
  end

  context 'when NULLABLE Date' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec(int Nullable(Int8), date Nullable(Date)) ENGINE TinyLog
      SQL

      subject.execute <<~SQL
        INSERT INTO rspec VALUES (NULL, NULL), (10, '2019-01-01')
      SQL
    end

    context 'when values exists' do
      let(:expectation) do
        { 'int' => 10, 'date' => Date.new(2019, 1, 1) }
      end

      it 'works' do
        expect(subject.select_one('SELECT * FROM rspec WHERE int IS NOT NULL')).to eq(expectation)
      end
    end

    context 'when values empty' do
      let(:expectation) do
        { 'int' => nil, 'date' => nil }
      end

      it 'works' do
        expect(subject.select_one('SELECT * FROM rspec WHERE int IS NULL')).to eq(expectation)
      end
    end
  end

  context 'when NULLABLE Decimal' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec(int Nullable(Decimal(10, 10))) ENGINE TinyLog
      SQL

      subject.execute <<~SQL
        INSERT INTO rspec VALUES (NULL), (0.123456789)
      SQL
    end

    context 'when values exists' do
      let(:expectation) do
        { 'int' => BigDecimal(0.123456789, 10) }
      end

      it 'works' do
        expect(subject.select_one('SELECT * FROM rspec WHERE int IS NOT NULL')).to eq(expectation)
      end
    end

    context 'when values empty' do
      let(:expectation) do
        { 'int' => nil }
      end

      it 'works' do
        expect(subject.select_one('SELECT * FROM rspec WHERE int IS NULL')).to eq(expectation)
      end
    end
  end

  context 'when NULLABLE IPv4' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec(ip Nullable(IPv4)) ENGINE TinyLog
      SQL

      subject.execute <<~SQL
        INSERT INTO rspec VALUES (NULL), ('127.0.0.1')
      SQL
    end

    context 'when values exists' do
      let(:expectation) do
        { 'ip' => IPAddr.new('127.0.0.1') }
      end

      it 'works' do
        expect(subject.select_one('SELECT * FROM rspec WHERE ip IS NOT NULL')).to eq(expectation)
      end
    end

    context 'when values empty' do
      let(:expectation) do
        { 'ip' => nil }
      end

      it 'works' do
        expect(subject.select_one('SELECT * FROM rspec WHERE ip IS NULL')).to eq(expectation)
      end
    end
  end

  context 'when NULLABLE IPv6' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec(ip Nullable(IPv6)) ENGINE TinyLog
      SQL

      subject.execute <<~SQL
        INSERT INTO rspec VALUES (NULL), ('::1')
      SQL
    end

    context 'when values exists' do
      let(:expectation) do
        { 'ip' => IPAddr.new('::1') }
      end

      it 'works' do
        expect(subject.select_one('SELECT * FROM rspec WHERE ip IS NOT NULL')).to eq(expectation)
      end
    end

    context 'when values empty' do
      let(:expectation) do
        { 'ip' => nil }
      end

      it 'works' do
        expect(subject.select_one('SELECT * FROM rspec WHERE ip IS NULL')).to eq(expectation)
      end
    end
  end
end
