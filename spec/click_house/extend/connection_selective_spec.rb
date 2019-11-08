RSpec.describe ClickHouse::Extend::ConnectionSelective do
  subject do
    ClickHouse.connection
  end

  describe '#select_value' do
    context 'when exists' do
      it 'works' do
        expect(subject.select_value('SELECT 13')).to eq(13)
      end
    end

    context 'when not exists' do
      it 'works' do
        expect(subject.select_value('SELECT null')).to eq(nil)
      end
    end

    context 'when multiple columns' do
      it 'works' do
        expect(subject.select_value('SELECT 1, 2, 3, 4, 5')).to eq(1)
      end
    end
  end

  describe '#select_one' do
    context 'when exists' do
      it 'works' do
        expect(subject.select_one('SELECT 1 AS foo, 2 AS bar')).to eq({ 'foo' => 1, 'bar' => 2 })
      end
    end

    context 'when not exists' do
      it 'works' do
        expect(subject.select_one('SELECT NULL')).to eq({ 'NULL' => nil })
      end
    end
  end

  describe '#select_all' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec (date Date, id UInt32) ENGINE = MergeTree(date, (id, date), 8192)
      SQL

      subject.execute <<~SQL
        INSERT INTO rspec (date, id) VALUES('2000-01-01', 1), ('2000-01-02', 2)
      SQL
    end

    context 'when empty' do
      it 'works' do
        expect(subject.select_all('SELECT * FROM rspec where id = 100').to_a).to eq([])
      end
    end

    context 'when exists' do
      let(:expectation) do
        [
          { 'date' => Date.new(2000, 1, 1), 'id' => 1 },
          { 'date' => Date.new(2000, 1, 2), 'id' => 2 }
        ]
      end

      it 'works' do
        expect(subject.select_all('SELECT * FROM rspec').to_a).to match_array(expectation)
      end
    end
  end
end
