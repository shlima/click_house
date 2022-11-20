# frozen_string_literal: true

RSpec.describe 'Different formats' do
  subject do
    ClickHouse.connection
  end

  context 'when RowBinary' do
    it 'works' do
      got = subject.select_one('SELECT 1 FORMAT RowBinary')
      expect(got).to eq("\u0001")
    end

    it 'has summary' do
      got = subject.select_all('SELECT 1 FORMAT RowBinary')
      expect(got.summary.read_rows).to eq(1)
    end
  end

  context 'when CSB' do
    it 'works' do
      got = subject.select_one('SELECT 1 FORMAT CSV')
      expect(got).to eq(['1'])
    end

    it 'has summary' do
      got = subject.select_all('SELECT 1 FORMAT CSV')
      expect(got.summary.read_rows).to eq(1)
    end
  end
end
