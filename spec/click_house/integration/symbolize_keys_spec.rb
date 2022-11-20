# frozen_string_literal: true

RSpec.describe ClickHouse::Config do
  subject do
    ClickHouse::Connection.new(ClickHouse.config.clone.assign(symbolize_keys: true))
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a String,
      ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
           'foo'
        );
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got).to eq({a: "foo"})

      got = subject.select_value('SELECT * FROM rspec')
      expect(got).to eq("foo")

      got = subject.select_all('SELECT * FROM rspec')
      expect(got.meta).to eq([{:name=>"a", :type=>"String"}])
      expect(got.statistics).to include(rows_read: 1)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        a: 'foo'
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch(:a)).to eq(row.fetch(:a))
    end
  end
end
