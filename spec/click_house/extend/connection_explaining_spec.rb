RSpec.describe ClickHouse::Extend::ConnectionExplaining do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(id Int64) ENGINE TinyLog
    SQL
  end

  let(:expectation) do
    <<~TXT
      Expression (Projection)
        CreatingSets (Create sets before main query execution)
          Expression (Before ORDER BY and SELECT)
            Join (JOIN)
              Expression (Before JOIN)
                ReadFromStorage (Read from TinyLog)
          CreatingSet (Create set for JOIN)
            Expression (Projection)
              Expression (Before ORDER BY and SELECT)
                ReadFromStorage (Read from TinyLog)
    TXT
  end

  context 'when normal query' do
    it 'works' do
      buffer = StringIO.new
      subject.explain('SELECT 1 FROM rspec CROSS JOIN rspec', io: buffer)
      expect(buffer.string).to eq(expectation)
    end
  end

  context 'when EXPLAIN query' do
    it 'works' do
      buffer = StringIO.new
      subject.explain(' explain SELECT 1 FROM rspec CROSS JOIN rspec', io: buffer)
      expect(buffer.string).to eq(expectation)
    end
  end
end
