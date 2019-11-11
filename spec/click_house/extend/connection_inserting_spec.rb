# ⚠️ INSERT IN TESTS SHOULD HAVE A DIFFERENT ORDER OF COLUMNS
#   FROM THE ORDER IN THE TABLE ITSELF
RSpec.describe ClickHouse::Extend::ConnectionInserting do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(id Int64, name String, date Nullable(Date)) ENGINE TinyLog
    SQL
  end

  context 'when block' do
    let(:insert) do
      subject.insert('rspec', columns: %i[name id], values: [['Sun', 1], ['Moon', 2]])
    end

    it 'works' do
      expect(insert).to eq(true)
      expect(subject.select_value('SELECT COUNT(*) FROM rspec')).to eq(2)
    end
  end

  context 'when params' do
    let(:insert) do
      subject.insert('rspec', columns: %i[name id]) do |buffer|
        buffer << ['Sun', 1]
        buffer << ['Moon', 2]
      end
    end

    it 'works' do
      expect(insert).to eq(true)
      expect(subject.select_value('SELECT COUNT(*) FROM rspec')).to eq(2)
    end
  end

  context 'when empty' do
    let(:insert) do
      subject.insert('rspec', columns: %i[id name], values: [])
    end

    it 'works' do
      expect(insert).to eq(true)
      expect(subject.select_value('SELECT COUNT(*) FROM rspec')).to eq(0)
    end
  end

  context 'when Nullable column' do
    let(:insert) do
      subject.insert('rspec', columns: %i[date id name], values: [[nil, 1, 'foo']])
    end

    it 'works' do
      expect(insert).to eq(true)
      expect(subject.select_value('SELECT COUNT(*) FROM rspec')).to eq(1)
    end
  end
end

