RSpec.describe ClickHouse::Type::DateTime64Type do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a DateTime64(0),
          b DateTime64(0, 'Europe/Kyiv'),
          c Nullable(DateTime64(0)),
          d Nullable(DateTime64(0, 'Europe/Kyiv')),
          e Nullable(DateTime64(0)),
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      insert into rspec values (
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
