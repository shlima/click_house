RSpec.describe ClickHouse::Connection do
  context 'when basic auth' do
    subject do
      ClickHouse::Connection.new(ClickHouse.config.clone.assign(
        username: 'user',
        password: 'password'
      ))
    end

    it 'works' do
      expect { subject.tables }.to raise_error(ClickHouse::DbException, /Authentication failed/)
    end
  end

  context 'when errors in response' do
    let(:connection) { ClickHouse::Connection.new(config) }
    let(:config) { ClickHouse.config.clone.assign(url: 'http://stub/') }

    it 'raises a DbException' do
      stub_request(:get, /stub/)
        .to_return(
          body: "Code: 159. DB::Exception: Timeout exceeded: elapsed 1.009405197 seconds, maximum: 1. (TIMEOUT_EXCEEDED) (version 23.5.4.25 (official build))\n",
          status: 200,
          headers: { 'X-ClickHouse-Exception-Code' => '159', 'Content-Type' => 'application/json; charset=UTF-8' }
        )

      expect { connection.get(body: 'SELECT 1') }.to raise_error(ClickHouse::DbException, /Timeout exceeded/)
    end
  end
end
