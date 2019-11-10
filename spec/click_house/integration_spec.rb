RSpec.describe ClickHouse do
  subject do
    described_class.connection
  end

  describe 'insert array of stings' do
    before do
      subject.create_table('rspec', engine: 'TinyLog') do |t|
        t << 'tags Array(String)'
      end

      string_type = ClickHouse::Type::StringType.new
      array_of_string = ClickHouse::Type::ArrayType.new(string_type)

      subject.insert('rspec', columns: ['tags']) do |buffer|
        buffer << [array_of_string.serialize(['Berger King', "McDonald’s"])]
      end
    end

    it 'works' do
      expect(subject.select_one('SELECT * FROM rspec')).to eq('tags' => ['Berger King', "McDonald’s"])
    end
  end
end
