RSpec.describe ClickHouse::Response::Factory do
  subject do
    ClickHouse.connection
  end

  describe 'WITH totals modifier' do
    context 'when blank' do
      let(:response) do
        subject.select_all('SELECT 1')
      end

      it 'is empty' do
        expect(response.totals).to eq(nil)
      end
    end

    context 'when exists' do
      let(:response) do
        subject.select_all('SELECT SUM(1) AS s WITH TOTALS')
      end

      it 'is present' do
        expect(response.totals).to eq({ 's' => '1' })
      end
    end
  end
end
