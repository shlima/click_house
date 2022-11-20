# frozen_string_literal: true

RSpec.describe ClickHouse::Type::FloatType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a Float32,
          b Float64,        
          c Nullable(Float64)
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
            1.1,
            2.2,
            NULL
        );
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.fetch('a')).to eq(1.1)
      expect(got.fetch('b')).to eq(2.2)
      expect(got.fetch('c')).to eq(nil)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => 1.1,
        'b' => 2.2,
        'c' => nil,
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to eq(row.fetch('a'))
      expect(got.fetch('b')).to eq(row.fetch('b'))
      expect(got.fetch('c')).to eq(row.fetch('c'))
    end
  end
end
