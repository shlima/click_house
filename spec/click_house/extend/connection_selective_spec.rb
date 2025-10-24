# frozen_string_literal: true

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

    context 'when invalid query' do
      it 'raises DbException for unknown function' do
        expect { subject.select_value('SELECT unknownFunction()') }.to raise_error(ClickHouse::DbException)
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

    context 'when invalid query' do
      it 'raises DbException for unknown function' do
        expect { subject.select_one('SELECT unknownFunction()') }.to raise_error(ClickHouse::DbException)
      end
    end
  end

  describe '#select_all' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec (date Date, id UInt32) ENGINE TinyLog
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

    context 'when invalid query' do
      it 'raises DbException for unknown function' do
        expect { subject.select_all('SELECT unknownFunction()') }.to raise_error(ClickHouse::DbException)
      end

      it 'raises DbException for non-existent table' do
        expect { subject.select_all('SELECT * FROM nonexistent_table_xyz') }.to raise_error(ClickHouse::DbException)
      end

      it 'raises DbException with error message for invalid syntax' do
        expect { subject.select_all('SELECT * FROM') }.to raise_error(ClickHouse::DbException, /Exception/)
      end
    end
  end
end
