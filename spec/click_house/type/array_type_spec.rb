RSpec.describe ClickHouse::Type::ArrayType do
  context 'when Array of strings' do
    def target(value)
      described_class.new(ClickHouse::Type::StringType.new).serialize(value)
    end

    it 'works' do
      expect(target(nil)).to eq(nil)
      expect(target([])).to eq([])
      expect(target(%w[foo bar])).to eq(%w[foo bar])
    end
  end
end
