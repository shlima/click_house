RSpec.describe ClickHouse::Definition::ColumnSet do
  def squish(string)
    string.gsub(/[[:space:]]/, '').strip
  end

  context 'when integration' do
    subject do
      described_class.new do |t|
        t.Decimal :money, 5, 5
        t.Float32 :city_id, default: 0, nullable: true
        t.Nested :json do |n|
          n.UInt8 :cid, nullable: true
          n.Date  :created_at, default: 'NOW()'
          n.DateTime :updated_at, 'UTC'
        end
        t << "words Enum('hello' = 1, 'world' = 2)"
        t << "tags Array(String)"
      end
    end

    let(:expectation) do
      <<~SQL
        ( 
          money Decimal(5, 5), 
          city_id Nullable(Float32) DEFAULT 0, 
          json Nested ( 
                        cid Nullable(UInt8) , 
                        created_at Date DEFAULT NOW(), 
                        updated_at DateTime('UTC')  
                      ), 
          words Enum('hello' = 1, 'world' = 2), 
          tags Array(String) 
        )
      SQL
    end

    it 'works' do
      expect(squish(subject.to_s)).to eq(squish(expectation))
    end
  end
end
