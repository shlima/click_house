# frozen_string_literal: true

RSpec.describe ClickHouse::Response::Factory do
  subject do
    ClickHouse.connection
  end

  describe '.response' do
    let(:config) { ClickHouse::Config.new }
    let(:faraday_env) { {} }
    let(:summary_middleware) { instance_double(ClickHouse::Middleware::SummaryMiddleware) }

    before do
      allow(ClickHouse::Middleware::SummaryMiddleware).to receive(:extract).and_return(double('summary'))
    end

    context 'when response contains exception field' do
      let(:faraday_response) do
        double('Faraday::Response',
               body: { 'exception' => 'Code: 46. DB::Exception: Unknown function' },
               env: faraday_env)
      end

      it 'raises DbException' do
        expect do
          ClickHouse::Response::Factory.response(faraday_response, config)
        end.to raise_error(ClickHouse::DbException, /Unknown function/)
      end
    end

    context 'when response contains valid data' do
      let(:faraday_response) do
        double('Faraday::Response',
               body: { 'meta' => [], 'data' => [] },
               env: faraday_env)
      end

      it 'returns ResultSet' do
        result = ClickHouse::Response::Factory.response(faraday_response, config)
        expect(result).to be_a(ClickHouse::Response::ResultSet)
      end
    end

    context 'when response is not a Hash' do
      let(:faraday_response) do
        double('Faraday::Response',
               body: 'plain text response',
               env: faraday_env)
      end

      it 'returns raw ResultSet' do
        result = ClickHouse::Response::Factory.response(faraday_response, config)
        expect(result).to be_a(ClickHouse::Response::ResultSet)
      end
    end
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
