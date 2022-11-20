RSpec.describe ClickHouse::Type::DecimalType do
  describe '#casr' do
    context 'when String' do
      it 'works' do
        expect(subject.cast("1.0")).to eq(BigDecimal(1.0, 1))
      end
    end

    context 'when BigDecimal' do
      it 'works' do
        expect(subject.cast(BigDecimal(1))).to eq(BigDecimal(1))
      end
    end

    context 'when Float' do
      it 'works' do
        expect(subject.cast(1.0, 1)).to eq(BigDecimal(1.0, 1))
        expect(subject.cast(1.0)).to eq(BigDecimal(1.0, ClickHouse::Type::DecimalType::MAXIMUM))
      end
    end
  end
end
