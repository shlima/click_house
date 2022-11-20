RSpec.describe ClickHouse::Response::ResultSet do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a Boolean,
          b Array(Nullable(String))
       ) ENGINE Memory
    SQL
  end

  let(:schema) do
    subject.table_schema('rspec')
  end

  describe '#types' do
    it 'works' do
      expect(schema.types).to have_key('a')
      expect(schema.types).to have_key('b')
    end
  end

  describe '#serialize_column' do
    it 'works' do
      expect(schema.serialize_column('a', true)).to eq(1)
      expect(schema.serialize_column('b', [])).to eq([])
    end

    it 'errors if column missing' do
      expect { schema.serialize_column('foo', 'bar') }.to raise_error(ClickHouse::SerializeError)
    end

    it 'errors if value has improper type' do
      expect { schema.serialize_column('b', nil) }.to raise_error(ClickHouse::SerializeError)
    end
  end

  describe '#serialize_one' do
    it 'works' do
      expect(schema.serialize_one({'a' => true, 'b' => ['foo']})).to eq({'a' => 1, 'b' => ['foo']})
    end
  end

  describe '#serialize' do
    let(:row) do
      {'a' => true, 'b' => ['foo']}
    end

    let(:expectation) do
      {'a' => 1, 'b' => ['foo']}
    end

    context 'when Hash' do
      it 'works' do
        expect(schema.serialize(row)).to eq(expectation)
      end
    end

    context 'when Array' do
      it 'works' do
        expect(schema.serialize([row])).to eq([expectation])
      end
    end

    context 'when other' do
      it 'errors' do
        expect { schema.serialize(nil) }.to raise_error(ArgumentError)
      end
    end
  end
end
