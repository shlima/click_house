RSpec.describe ClickHouse::Type::ArrayType do
  context 'when Array of strings' do
    def target(value)
      described_class.new(ClickHouse::Type::StringType  .new).serialize(value)
    end

    it 'works' do
      expect(target([])).to eq('[]')
      expect(target(%w[foo bar])).to eq("['foo','bar']")
    end

    it 'escapes single quote' do
      expect(target(%w['hello' la'burge])).to eq(%q{['\hello\','la\burge']})
    end
  end
end
