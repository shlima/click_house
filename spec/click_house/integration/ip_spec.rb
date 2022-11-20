# frozen_string_literal: true

RSpec.describe ClickHouse::Type::IPType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a IPv4,
          b Nullable(IPv4),
          c IPv6,
          d Nullable(IPv6)
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
          '127.0.0.1',
          '127.0.0.1',
          '::1',
          NULL
        );
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.fetch('a')).to eq(IPAddr.new('127.0.0.1'))
      expect(got.fetch('b')).to eq(IPAddr.new('127.0.0.1'))
      expect(got.fetch('c')).to eq(IPAddr.new('::1'))
      expect(got.fetch('d')).to eq(nil)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => IPAddr.new('127.0.0.1'),
        'b' => '127.0.0.1', # as string
        'c' => IPAddr.new('::1'),
        'd' => nil
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to eq(row.fetch('a'))
      expect(got.fetch('b')).to eq(IPAddr.new(row.fetch('b')))
      expect(got.fetch('c')).to eq(row.fetch('c'))
      expect(got.fetch('d')).to eq(row.fetch('d'))
    end
  end
end
