RSpec.describe ClickHouse::Type::DateTime64Type do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a DateTime64(9),
          b DateTime64(9, 'Europe/Kyiv'),
          c Nullable(DateTime64(9)),
          d Nullable(DateTime64(9, 'Europe/Kyiv')),
          e Nullable(DateTime64(9)),
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec values (
          now(),
          now(),
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

      expect(got.fetch('c')).to be_a(Time)
      expect(got.fetch('d')).to be_a(Time)
      expect(got.fetch('d')).to have_attributes(zone: Time.find_zone('Europe/Kyiv').tzinfo.abbr)

      expect(got.fetch('e')).to be_a(NilClass)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => Time.now,
        'b' => Time.find_zone("Europe/Kyiv").now,
        'c' => Time.now,
        'd' => nil,
        'e' => nil,
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
    end
  end
end
