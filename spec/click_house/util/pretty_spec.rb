RSpec.describe ClickHouse::Util::Pretty do
  describe '#size' do
    let(:expectation) do
      {
        0 => '0B',
        100 => '100.0B',
        1456 => '1.4KiB',
        1024000 * 2 => '2.0MiB',
        10737418240 => '10.0GiB',
        10737418240 * 1_000 => '9.8TiB',
      }
    end

    it 'works' do
      expectation.each do |bytes, pretty|
        expect(described_class.size(bytes)).to eq(pretty)
      end
    end
  end
end
