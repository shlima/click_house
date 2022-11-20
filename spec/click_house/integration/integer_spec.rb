# frozen_string_literal: true

RSpec.describe ClickHouse::Type::IntegerType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a UInt8,
          b UInt16,
          c UInt32, 
          d UInt64,
          e Int8,
          f Int16,
          g Int32,
          h Int64,
          k Nullable(Int64)
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            NULL
        );
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.fetch('a')).to eq(1)
      expect(got.fetch('b')).to eq(2)
      expect(got.fetch('c')).to eq(3)
      expect(got.fetch('d')).to eq(4)
      expect(got.fetch('e')).to eq(5)
      expect(got.fetch('f')).to eq(6)
      expect(got.fetch('g')).to eq(7)
      expect(got.fetch('h')).to eq(8)
      expect(got.fetch('k')).to eq(nil)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => 1,
        'b' => 2,
        'c' => 3,
        'd' => 4,
        'e' => 5,
        'f' => 6,
        'g' => 7,
        'h' => 8,
        'k' => nil,
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to eq(row.fetch('a'))
      expect(got.fetch('b')).to eq(row.fetch('b'))
      expect(got.fetch('c')).to eq(row.fetch('c'))
      expect(got.fetch('d')).to eq(row.fetch('d'))
      expect(got.fetch('e')).to eq(row.fetch('e'))
      expect(got.fetch('f')).to eq(row.fetch('f'))
      expect(got.fetch('g')).to eq(row.fetch('g'))
      expect(got.fetch('h')).to eq(row.fetch('h'))
      expect(got.fetch('k')).to eq(row.fetch('k'))
    end
  end
end
