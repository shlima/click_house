# frozen_string_literal: true

RSpec.describe ClickHouse::Type::BooleanType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a Boolean,
          b Boolean,
          b Nullable(Boolean)
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
        1,
        0,
        NULL
      );
    SQL
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a')).to be_a(TrueClass)
    expect(got.fetch('b')).to be_a(FalseClass)
    expect(got.fetch('c')).to be_a(NilClass)
  end
end
