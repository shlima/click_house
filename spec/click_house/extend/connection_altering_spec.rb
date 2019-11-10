RSpec.describe ClickHouse::Extend::ConnectionAltering do
  subject do
    ClickHouse.connection
  end

  describe '#add_column' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec (date Date, id UInt32, user_id UInt32) ENGINE = MergeTree(date, (id, date), 8192)
      SQL
    end

    context 'when not exists' do
      before do
        subject.add_column(:rspec, :account_id, :UInt64, default: 0, after: :date)
      end

      let(:column) do
        subject.describe_table('rspec').find { |r| r['name'] == 'account_id' }
      end

      it 'works' do
        expect(subject.describe_table('rspec').map { |r| r['name'] }).to eq(%w[date account_id id user_id])
        expect(column).to include('type' => 'UInt64')
        expect(column).to include('default_expression' => "CAST(0, 'UInt64')")
      end
    end

    context 'when exists' do
      let(:function) do
        subject.add_column(:rspec, :user_id, 'UInt32')
      end

      it 'errors' do
        expect { function }.to raise_error(ClickHouse::DbException)
      end
    end

    context 'when if not exists' do
      let(:function) do
        subject.add_column(:rspec, :user_id, 'UInt32', if_not_exists: true)
      end

      it 'works' do
        expect(function).to eq(true)
      end
    end
  end

  describe '#drop_column' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec (date Date, id UInt32, int_1 UInt32) ENGINE = MergeTree(date, (id, date), 8192)
      SQL
    end

    context 'when exists' do
      let(:function) do
        subject.drop_column('rspec', :int_1)
      end

      it 'works' do
        expect { function }.to change { subject.describe_table('rspec').length }.by(-1)
      end
    end

    context 'when not exists' do
      let(:function) do
        subject.drop_column('rspec', :foo)
      end

      it 'errors' do
        expect { function }.to raise_error(ClickHouse::DbException)
      end
    end

    context 'when if exists' do
      let(:function) do
        subject.drop_column('rspec', :foo, if_exists: true)
      end

      it 'works' do
        expect(function).to eq(true)
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
