RSpec.describe ClickHouse::Type::LowCardinalityType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a LowCardinality(DateTime),
          b LowCardinality(DateTime('Europe/Kyiv')),
          c LowCardinality(Nullable(String))
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
          now(),
          now(),
          null
        );
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.fetch('a')).to be_a(Time)
      expect(got.fetch('a')).to have_attributes(zone: Time.now.zone)

      expect(got.fetch('b')).to be_a(Time)
      expect(got.fetch('b')).to have_attributes(zone: Time.find_zone('Europe/Kyiv').tzinfo.abbr)

      expect(got.fetch('c')).to be_a(NilClass)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => Time.now,
        'b' => Time.now,
        'c' => nil,
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to be_a(Time)
      expect(got.fetch('b')).to be_a(Time)
      expect(got.fetch('c')).to be_a(NilClass)
    end
  end
end
