# ⚠️ INSERT IN TESTS SHOULD HAVE A DIFFERENT ORDER OF COLUMNS
#   FROM THE ORDER IN THE TABLE ITSELF
RSpec.describe ClickHouse::Extend::ConnectionInserting do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(id Int64, name Nullable(String)) ENGINE Memory
    SQL
  end

  def expected(insert, count)
    expect(insert.written_rows).to eq(count)
    expect(subject.select_value('SELECT COUNT(*) FROM rspec')).to eq(count)
  end

  context 'when blank' do
    let(:insert) do
      subject.insert('rspec')
    end

    it 'works' do
      expected(insert, 0)
    end
  end

  context 'when columns with blank values' do
    let(:insert) do
      subject.insert('rspec', columns: %i[id name])
    end

    it 'works' do
      expected(insert, 0)
    end
  end

  describe 'execution' do
    let(:insert) do
      subject.insert('rspec', values: {id: 1, name: 'foo'})
    end

    it 'has proper attributes' do
      expect(insert.read_rows).to be > 0
      expect(insert.read_bytes).to be > 0
      expect(insert.written_rows).to be > 0
      expect(insert.written_bytes).to be > 0
      expect(insert.result_rows).to be > 0
      expect(insert.result_bytes).to be > 0
      expect(insert.summary).not_to be_empty
      expect(insert.headers).not_to be_empty
    end
  end

  context 'when body', if: ruby_version_gt('3') do
    context 'when Hash' do
      let(:insert) do
        subject.insert('rspec', {id: 1, name: 'foo'})
      end

      it 'works' do
        expected(insert, 1)
      end
    end

    context 'when Array' do
      let(:insert) do
        subject.insert('rspec', [{id: 1, name: 'foo'}, {id: 1, name: 'foo'}])
      end

      it 'works' do
        expected(insert, 2)
      end
    end
  end

  context 'when body', if: ruby_version_lt('3') do
    context 'when Hash' do
      let(:insert) do
        subject.insert('rspec', {id: 1, name: 'foo'}, {})
      end

      it 'works' do
        expected(insert, 1)
      end
    end

    context 'when Array' do
      let(:insert) do
        subject.insert('rspec', [{id: 1, name: 'foo'}, {id: 1, name: 'foo'}], {})
      end

      it 'works' do
        expected(insert, 2)
      end
    end
  end

  context 'when block with columns' do
    let(:insert) do
      subject.insert('rspec', columns: %i[name id], values: [['Sun', 1], ['Moon', 2]])
    end

    it 'works' do
      expected(insert, 2)
    end

    context 'when string format' do
      let(:insert) do
        subject.insert('rspec', columns: %i[name id], values: [%w[Sun 1], %w[Moon 2]], format: 'JSONCompactStringsEachRow')
      end

      it 'works' do
        expected(insert, 2)
      end
    end
  end

  context 'when argument with columns' do
    let(:insert) do
      subject.insert('rspec', columns: %i[name id]) do |buffer|
        buffer << ['Sun', 1]
        buffer << ['Moon', 2]
      end
    end

    it 'works' do
      expected(insert, 2)
    end
  end

  context 'when hash with argument' do
    let(:insert) do
      subject.insert('rspec', values: [{ name: 'Sun', id: 1 }, { name: 'Moon', id: 2 }])
    end

    it 'works' do
      expected(insert, 2)
    end
  end

  context 'when hash with block' do
    let(:insert) do
      subject.insert('rspec') do |buffer|
        buffer << { name: 'Sun', id: 1 }
        buffer << { name: 'Moon', id: 2 }
      end
    end

    it 'works' do
      expected(insert, 2)
    end
  end
end
