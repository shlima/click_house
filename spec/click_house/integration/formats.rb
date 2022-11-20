# frozen_string_literal: true

RSpec.describe ClickHouse::Extend::ConnectionSelective do
  subject do
    ClickHouse.connection
  end

  context 'when RowBinary' do
    let(:query) do
      'SELECT 1 FORMAT RowBinary'
    end

    it '#select_one' do
      got = subject.select_one(query)
      expect(got).to eq("\u0001")
    end

    it '#select_value' do
      got = subject.select_value(query)
      expect(got).to eq("\u0001")
    end

    it '#summary' do
      got = subject.select_all(query)
      expect(got.summary.read_rows).to eq(1)
    end

    it '#types' do
      got = subject.select_all(query)
      expect(got.types).to eq([])
    end
  end

  context 'when CSV' do
    let(:query) do
      'SELECT 1 FORMAT CSV'
    end

    it '#select_one' do
      got = subject.select_one(query)
      expect(got).to eq(['1'])
    end

    it '#select_value' do
      got = subject.select_value(query)
      expect(got).to eq('1')
    end

    it '#summary' do
      got = subject.select_all(query)
      expect(got.summary.read_rows).to eq(1)
    end

    it '#types' do
      got = subject.select_all(query)
      expect(got.types).to eq([])
    end
  end
end
