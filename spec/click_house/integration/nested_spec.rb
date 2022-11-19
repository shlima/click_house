# frozen_string_literal: true

RSpec.describe 'Nested' do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
        json Nested(
          a Date
        ) 
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
        (['2022-01-01']) 
      )
    SQL
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('json.a')).to eq([Date.new(2022, 1, 1)])
  end
end
