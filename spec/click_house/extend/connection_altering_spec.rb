RSpec.describe ClickHouse::Extend::ConnectionAltering do
  subject do
    ClickHouse.connection
  end

  describe '#add_column' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec (date Date, id UInt32) ENGINE = MergeTree(date, (id, date), 8192)
      SQL
    end

    context 'when not exists' do
      before do
        subject.add_column(:rspec, :user_id, :UInt64, default: 0, after: :date)
      end

      let(:column) do
        subject.describe_table('rspec').find { |r| r['name'] == 'user_id' }
      end

      it 'works' do
        expect(subject.describe_table('rspec').map { |r| r['name'] }).to eq(%w[date user_id id])
        expect(column).to include('type' => 'UInt64')
        expect(column).to include('default_expression' => "CAST(0, 'UInt64')")
      end
    end
  end

  describe '#alter_table' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec (date Date, id UInt32, int_1 UInt32) ENGINE = MergeTree(date, (id, date), 8192)
      SQL
    end

    context 'when argument' do
      let(:function) do
        subject.alter_table('rspec', 'DROP COLUMN int_1')
      end

      it 'works' do
        expect { function }.to change { subject.describe_table('rspec').length }.by(-1)
      end
    end

    context 'when block' do
      let(:function) do
        subject.alter_table('rspec') do
          'DROP COLUMN int_1'
        end
      end

      it 'works' do
        expect { function }.to change { subject.describe_table('rspec').length }.by(-1)
      end
    end
  end
end
