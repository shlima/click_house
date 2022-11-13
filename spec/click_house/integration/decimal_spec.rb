RSpec.describe ClickHouse::Type do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a Decimal(10,10),
          b Decimal32(1),
          c Decimal64(10),
          d Decimal128(20),
          e Decimal256(30)
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
        0.1,
        1/3,
        1/3,
        1/3,
        1/3
      );
    SQL
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a')).to be_a(BigDecimal)
    expect(got.fetch('b')).to be_a(BigDecimal)
    expect(got.fetch('c')).to be_a(BigDecimal)
    expect(got.fetch('d')).to be_a(BigDecimal)
    expect(got.fetch('e')).to be_a(BigDecimal)
  end

  it 'cast type with correct precision', if: ruby_version_gt('2.8') do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a').precision).to eq(1)
    expect(got.fetch('b').precision).to eq(1)
    expect(got.fetch('c').precision).to eq(10)
    expect(got.fetch('d').precision).to eq(20)
    expect(got.fetch('e').precision).to eq(30)
  end
end