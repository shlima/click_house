RSpec.describe ClickHouse::Connection do
  context 'when basic auth' do
    subject do
      ClickHouse::Connection.new(ClickHouse.config.clone.assign(
        username: 'user',
        password: 'password'
      ))
    end

    it 'works' do
      expect {  subject.tables }.to raise_error(ClickHouse::DbException, /Authentication failed/)
    end
  end
end
