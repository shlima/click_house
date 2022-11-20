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
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
          (['2022-01-01']) 
        )
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.fetch('json.a')).to eq([Date.new(2022, 1, 1)])
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'json.a' => [Date.new(2022, 1, 2)]
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('json.a')).to eq(row.fetch('json.a'))
    end
  end
end
