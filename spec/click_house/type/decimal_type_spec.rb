RSpec.describe ClickHouse::Type::DecimalType do
  describe '#serialize' do
    let(:input) do
      BigDecimal(10.fdiv(3), 0)
    end

    it 'works' do
      expect(subject.serialize(input)).to be_a(Float)
      expect(subject.serialize(input)).to eq(input.to_f)
    end
  end

  describe '#cast' do
    let(:input) do
      1.0e-05
    end

    it 'works' do
      expect(subject.cast(String(input))).to eq(input)
    end
  end
end
