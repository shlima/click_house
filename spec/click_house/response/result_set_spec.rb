RSpec.describe ClickHouse::Response::ResultSet do
  describe '.extract_type_info' do
    let(:expectations) do
      {
        "DateTime('Europe/Moscow')" => ["DateTime(%s)", ["'Europe/Moscow'"]],
        "Nullable(Decimal(10, 5))" => ["Nullable(Decimal(%d, %d))", ["10", "5"]],
        "Decimal(10, 5)" => ["Decimal(%d, %d)", ["10", "5"]],
        "DateTime64(3, 'UTC')" => ["DateTime64(%d, %s)", ["3", "'UTC'"]]
      }
    end

    it 'works' do
      expectations.each do |input, output|
        expect(described_class.extract_type_info(input)).to eq(output)
      end
    end
  end
end
