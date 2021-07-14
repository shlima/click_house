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
       Expression ((Projection + Before ORDER BY))
         Join (JOIN)
           Expression (Before JOIN)
             SettingQuotaAndLimits (Set limits and quota after reading from storage)
               ReadFromStorage (TinyLog)
           Expression ((Joined actions + (Rename joined columns + (Projection + Before ORDER BY))))
             SettingQuotaAndLimits (Set limits and quota after reading from storage)
               ReadFromStorage (TinyLog)
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
