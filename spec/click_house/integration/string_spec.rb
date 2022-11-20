# frozen_string_literal: true

RSpec.describe ClickHouse::Type::StringType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a String,
          b FixedString(2),
          c UUID, 
          d Nullable(UUID)
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
            'x',
            'y',
            'da70495b-1ff7-49e5-8feb-d657bd4ea1ea',
            NULL
        );
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.fetch('a')).to eq("x")
      expect(got.fetch('b')).to eq("y\u0000")
      expect(got.fetch('c')).to eq("da70495b-1ff7-49e5-8feb-d657bd4ea1ea")
      expect(got.fetch('d')).to eq(nil)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => 'foo',
        'b' => 'xe',
        'c' => "da70495b-1ff7-49e5-8feb-d657bd4ea1ea",
        'd' => nil
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to eq(row.fetch('a'))
      expect(got.fetch('b')).to eq(row.fetch('b'))
      expect(got.fetch('c')).to eq(row.fetch('c'))
      expect(got.fetch('d')).to eq(row.fetch('d'))
    end
  end
end
