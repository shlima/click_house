# frozen_string_literal: true

RSpec.describe 'Enum' do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
         a Enum('foo' = 1, 'bar' = 2),
         b Nullable(Enum('foo' = 1, 'bar' = 2))
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
          1, 
          NULL
        )
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.fetch('a')).to eq('foo')
      expect(got.fetch('b')).to eq(nil)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => 'foo',
        'b' => nil,
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to eq('foo')
      expect(got.fetch('b')).to eq(nil)
    end
  end
end
