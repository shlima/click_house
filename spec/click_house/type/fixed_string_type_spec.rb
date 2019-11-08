RSpec.describe ClickHouse::Type::FixedStringType do
  describe '#serialize' do
    def target(value, limit = nil)
      described_class.new.serialize(value, limit)
    end

    it 'works' do
      expect(target(nil)).to eq(nil)
      expect(target('foo bar')).to eq('foo bar')
      expect(target('foo bar', 1)).to eq('f')
      expect(target('foo bar', 2)).to eq('fo')
    end
  end
end
