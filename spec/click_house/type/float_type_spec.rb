RSpec.describe ClickHouse::Type::FloatType do
  describe '#serialize' do
    it 'works' do
      expect(subject.serialize(5)).to be_a(Float)
      expect(subject.serialize(5)).to eq(5.0)
      expect(subject.serialize(5.0)).to eq(5.0)
      expect(subject.serialize(nil)).to eq(nil)
    end
  end

  describe '#cast' do
    it 'works' do
      expect(subject.cast(5)).to be_a(Float)
      expect(subject.cast(5)).to eq(5.0)
      expect(subject.cast(5.0)).to eq(5.0)
      expect(subject.cast(nil)).to eq(nil)
    end
  end
end
