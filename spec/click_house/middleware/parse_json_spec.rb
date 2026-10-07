RSpec.describe ClickHouse::Middleware::ParseJson do
  let(:config) { ClickHouse::Config.new }
  let(:content_type) { 'application/json; charset=UTF-8' }
  let(:body) { '{"price":"1.5","amount":1.5}' }

  let(:connection) do
    Faraday.new do |conn|
      conn.response described_class, content_type: %r{application/json}, options: { config: config }
      conn.adapter :test do |stub|
        stub.get('/') { [200, { 'Content-Type' => content_type }, body] }
      end
    end
  end

  subject(:parsed_body) { connection.get('/').body }

  it 'parses the body with json_load_options' do
    expect(parsed_body).to eq('price' => '1.5', 'amount' => BigDecimal('1.5'))
    expect(parsed_body['amount']).to be_a(BigDecimal)
  end

  it 'passes json_load_options to JSON.parse as keyword arguments' do
    expect(JSON).to receive(:parse).with(body, **config.json_load_options).and_call_original
    parsed_body
  end

  context 'when symbolize_keys is enabled' do
    before { config.symbolize_keys = true }

    it 'symbolizes the keys' do
      expect(parsed_body.keys).to eq(%i[price amount])
    end
  end

  context 'when the body is blank' do
    let(:body) { ' ' }

    it 'leaves the body unparsed' do
      expect(parsed_body).to eq(' ')
    end
  end

  context 'when the content type is not JSON' do
    let(:content_type) { 'text/tab-separated-values' }

    it 'leaves the body unparsed' do
      expect(parsed_body).to eq(body)
    end
  end
end
