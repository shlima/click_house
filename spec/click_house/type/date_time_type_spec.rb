RSpec.describe ClickHouse::Type::DateTimeType do
  describe '#serialize' do
    let(:time) do
      Time.new(2019, 1, 1, 9, 5, 6)
    end

    it 'works' do
      expect(subject.serialize(time)).to eq('2019-01-01 09:05:06')
    end
  end

  describe '#cast' do
    context 'when zone is empty' do
      let(:time) do
        DateTime.new(2019, 1, 1, 9, 5, 6)
      end

      it 'works' do
        expect(subject.cast('2019-01-01 09:05:06')).to eq(time)
      end
    end

    context 'when zone exists' do
      let(:time) do
        DateTime.new(2019, 1, 1, 9, 5, 6, '+03')
      end

      it 'works' do
        expect(subject.cast('2019-01-01 09:05:06', '+03')).to eq(time)
      end
    end
  end
end
