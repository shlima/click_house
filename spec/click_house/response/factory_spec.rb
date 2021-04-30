RSpec.describe ClickHouse::Response::Factory do
  subject do
    ClickHouse.connection
  end

  describe 'WITH totals modifier' do
    context 'when blank' do
      it 'is empty' do
        expect(subject.select_all('SELECT 1').totals).to eq(nil)
      end
    end

    context 'when exists' do
      it 'is present' do
        expect(subject.select_all('SELECT SUM(1) AS s WITH TOTALS').totals).to eq({ 's' => '1' })
      end
    end
  end
end
