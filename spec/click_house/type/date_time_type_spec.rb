RSpec.describe ClickHouse::Type::DateTimeType do
  describe '#serialize' do
    let(:time) do
      Time.new(2019, 1, 1, 9, 5, 6)
    end

    it 'works' do
      expect(subject.serialize(time)).to eq('2019-01-01 09:05:06')
    end
  end
end
