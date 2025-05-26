RSpec.describe ClickHouse::Type::DateTime64Type do
  let(:precisions) do
    (0..9).to_a
  end

  describe '#serialize' do
    let(:time) do
      Time.new(2019, 1, 1, 9, 5, 6)
    end

    it 'works' do
      precisions.each do |precision|
        tail = "." + "0" * precision if precision > 0
        expect(subject.serialize(time, precision)).to eq("2019-01-01 09:05:06#{tail}")
      end
    end

    context 'when zone exists' do
      let(:time) do
        Time.new(2019, 1, 1, 9, 5, 6, Time.find_zone('UTC'))
      end

      it 'works' do
        precisions.each do |precision|
          tail = "." + "0" * precision if precision > 0
          expect(subject.serialize(time, precision, 'Europe/Kyiv')).to eq("2019-01-01 11:05:06#{tail}")
        end
      end
    end
  end

  describe '#cast' do
    context 'when zone is empty' do
      let(:time) do
        Time.new(2019, 1, 1, 9, 5, 6)
      end

      it 'works' do
        expect(subject.cast('2019-01-01 09:05:06.0000')).to eq(time)
      end
    end

    context 'when zone exists' do
      let(:time) do
        Time.new(2019, 1, 1, 9, 5, 6, Time.find_zone('Europe/Kyiv'))
      end

      it 'works' do
        expect(subject.cast('2019-01-01 09:05:06', 0, 'Europe/Kyiv').to_s).to eq(time.to_s)
        expect(subject.cast('2019-01-01 09:05:06.00', 9, 'Europe/Kyiv').to_s).to eq(time.to_s)
      end
    end
  end
end
