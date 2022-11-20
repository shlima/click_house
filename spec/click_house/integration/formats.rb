# frozen_string_literal: true

RSpec.describe ClickHouse::Extend::ConnectionSelective do
  subject do
    ClickHouse.connection
  end

  context 'when RowBinary' do
    it '#select_one' do
      got = subject.select_one('SELECT 1 FORMAT RowBinary')
      expect(got).to eq("\u0001")
    end

    it '#select_value' do
      got = subject.select_value('SELECT 1 FORMAT RowBinary')
      expect(got).to eq("\u0001")
    end

    it '#summary' do
      got = subject.select_all('SELECT 1 FORMAT RowBinary')
      expect(got.summary.read_rows).to eq(1)
    end
  end

  context 'when CSB' do
    it '#select_one' do
      got = subject.select_one('SELECT 1 FORMAT CSV')
      expect(got).to eq(['1'])
    end

    it '#select_value' do
      got = subject.select_value('SELECT 1 FORMAT CSV')
      expect(got).to eq('1')
    end

    it '#summary' do
      got = subject.select_all('SELECT 1 FORMAT CSV')
      expect(got.summary.read_rows).to eq(1)
    end
  end
end
