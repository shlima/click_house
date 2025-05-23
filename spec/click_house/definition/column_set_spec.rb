RSpec.describe ClickHouse::Definition::ColumnSet do
  def squish(string)
    string.gsub(/[[:space:]]/, '').strip
  end

  context 'when integration' do
    subject do
      described_class.new do |t|
        t.Decimal :money, 5, 5
        t.UInt16  :year_birth, low_cardinality: true
        t.UInt16  :year_death, low_cardinality: true, nullable: true, default: 0
        t.Float32 :city_id, default: 0, nullable: true
        t.DateTime :updated_at, 'UTC', default: 'NOW()'
        t.Nested :json do |n|
          n.UInt8 :cid, nullable: true
          n.Date  :created_at, default: 'NOW()'
          n.DateTime :updated_at, 'UTC'
          n.DateTime64 :deleted_at, 6, 'UTC'
        end
        t << "words Enum('hello' = 1, 'world' = 2)"
        t << "tags Array(String)"
      end
    end

    let(:expectation) do
      <<~SQL
        (
          money Decimal(5, 5),
          year_birth LowCardinality(UInt16),
          year_death LowCardinality(Nullable(UInt16)) DEFAULT 0,
          city_id Nullable(Float32) DEFAULT 0,
          updated_at DateTime('UTC') DEFAULT NOW(),
          json Nested (
                        cid Nullable(UInt8) ,
                        created_at Date DEFAULT NOW(),
                        updated_at DateTime('UTC'),
                        deleted_at DateTime64(6, 'UTC')
                      ),
          words Enum('hello' = 1, 'world' = 2),
          tags Array(String)
        )
      SQL
    end

    it 'works' do
      expect(subject.columns).to include(have_attributes default: "NOW()", extensions: ["UTC"], name: :updated_at, type: "DateTime('%s')") # Correctly handles columns with a mix of hash and non-hash arguments
      expect(squish(subject.to_s)).to eq(squish(expectation))
    end
  end
end
