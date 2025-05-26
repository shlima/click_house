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
          c Boolean,
          d Boolean,
          e Nullable(Boolean)
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
          1,
          0,
          true,
          false,
          NULL
        );
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.fetch('a')).to be_a(TrueClass)
      expect(got.fetch('b')).to be_a(FalseClass)
      expect(got.fetch('c')).to be_a(TrueClass)
      expect(got.fetch('d')).to be_a(FalseClass)
      expect(got.fetch('e')).to be_a(NilClass)
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => true,
        'b' => false,
        'c' => 1,
        'd' => 0,
        'e' => nil
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to be_a(TrueClass)
      expect(got.fetch('b')).to be_a(FalseClass)
      expect(got.fetch('c')).to be_a(TrueClass)
      expect(got.fetch('d')).to be_a(FalseClass)
      expect(got.fetch('e')).to be_a(NilClass)
    end
  end
end
