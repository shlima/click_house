RSpec.describe ClickHouse::Type::ArrayType do
  subject do
    ClickHouse.connection
  end

  describe 'cast' do
    context 'many flat' do
      before do
        subject.execute <<~SQL
          CREATE TABLE rspec(
              a Array(DateTime),
              b Array(Nullable(DateTime)),
              c Array(DateTime64(3)),
              d Array(Nullable(DateTime64(3))),
              e Array(DateTime64(3, 'UTC')),
              f Array(Nullable(DateTime64(3, 'UTC'))),
              g Array(Decimal(10,2)),
           ) ENGINE Memory
        SQL

        subject.execute <<~SQL
          insert into rspec values (
            array(now()),
            array(now()),
            array(now()),
            array(now()),
            array(now()),
            array(now()),
            array(5.99)
          );
        SQL
      end

      it 'works' do
        got = subject.select_one('SELECT * FROM rspec')
        expect(got.fetch('a').first).to be_a(Time)
        expect(got.fetch('b').first).to be_a(Time)
        expect(got.fetch('c').first).to be_a(Time)
        expect(got.fetch('d').first).to be_a(Time)
        expect(got.fetch('e').first).to be_a(Time)
        expect(got.fetch('f').first).to be_a(Time)
        expect(got.fetch('g').first).to be_a(BigDecimal)
      end
    end

    context 'many nested' do
      before do
        subject.execute <<~SQL
          CREATE TABLE rspec(
              a Array(Array(DateTime)),
              b Array(Array(Nullable(DateTime))),
              c Array(Array(Array(DateTime64(3)))),
              d Array(Array(Array(Array(Nullable(DateTime64(3)))))),
              e Array(Array(Array(Array(Array(DateTime64(3, 'UTC')))))),
              f Array(Array(Array(Array(Array(Array(Nullable(DateTime64(3, 'UTC')))))))),
              g Array(Array(Array(Array(Array(Array(Array(Decimal(10,2))))))))
           ) ENGINE TinyLog
        SQL

        subject.execute <<~SQL
          insert into rspec values (
            array(array(now())),
            array(array((now()))),
            array(array(array(((now()))))),
            array(array(array(array((((now()))))))),
            array(array(array(array(array((((now())))))))),
            array(array(array(array(array(array((((now()))))))))),
            array(array(array(array(array(array(array((((5.99))))))))))
          );
        SQL
      end

      it 'works' do
        got = subject.select_one('SELECT * FROM rspec')
        expect(got.fetch('a').dig(0, 0)).to be_a(Time)
        expect(got.fetch('b').dig(0, 0)).to be_a(Time)
        expect(got.fetch('c').dig(0, 0, 0)).to be_a(Time)
        expect(got.fetch('d').dig(0, 0, 0, 0)).to be_a(Time)
        expect(got.fetch('e').dig(0, 0, 0, 0, 0)).to be_a(Time)
        expect(got.fetch('f').dig(0, 0, 0, 0, 0, 0)).to be_a(Time)
        expect(got.fetch('g').dig(0, 0, 0, 0, 0, 0, 0)).to be_a(BigDecimal)
      end
    end
  end

  describe 'serialize' do
    before do
      subject.execute <<~SQL
          CREATE TABLE rspec(
              a Array(Bool),
              b Array(DateTime64(9, 'Europe/Kyiv')),
              c Array(Array(UInt8)),
              d Array(Array(Array(Nullable(UInt8)))),
           ) ENGINE Memory
      SQL
    end

    let(:row) do
      {
        'a' => [true],
        'b' => [Time.find_zone("Europe/Kyiv").now],
        'c' => [[1]],
        'd' => [[[nil]]]
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to eq(row.fetch('a'))
      expect(got.fetch('b')).to eq(row.fetch('b'))
      expect(got.fetch('c')).to eq(row.fetch('c'))
      expect(got.fetch('d')).to eq(row.fetch('d'))
    end
  end
end
