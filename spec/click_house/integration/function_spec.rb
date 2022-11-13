RSpec.describe 'Functions' do
  subject do
    ClickHouse.connection
  end

  let(:expectations) do 
    {
      'select NOW()' => Time,
      'select 1 + 1' => Integer,
      'select 1 * 1.0' => Float,
      'select empty([])' => Integer,
      'select 1 > 0' => Integer,
    }
  end

  it 'works' do
    expectations.each do |query, klass|
      expect(subject.select_value(query)).to be_a(klass)
    end  
  end
end
