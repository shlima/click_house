RSpec.describe ClickHouse::Type do
  subject do
    ClickHouse.connection
  end

  context 'when NULLABLE' do
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
end
