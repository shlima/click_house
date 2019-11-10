RSpec.describe ClickHouse::Extend::ConnectionTable do
  subject do
    ClickHouse.connection
  end

  describe '#tables' do
    context 'when empty' do
      it 'works' do
        expect(subject.tables).to eq([])
      end
    end

    context 'when exists' do
      before do
        subject.execute <<~SQL
          CREATE TABLE rspec (date Date, id UInt32) ENGINE = MergeTree(date, (id, date), 8192)
        SQL
      end

      it 'works' do
        expect(subject.tables).to contain_exactly('rspec')
      end
    end
  end

  describe '#table_exists?' do
    context 'when not exists' do
      it 'works' do
        expect(subject.table_exists?('foo')).to eq(false)
      end
    end

    context 'when exists' do
      before do
        subject.execute <<~SQL
          CREATE TABLE rspec (date Date, id UInt32) ENGINE = MergeTree(date, (id, date), 8192)
        SQL
      end

      it 'works' do
        expect(subject.table_exists?('rspec')).to eq(true)
      end
    end
  end

  describe '#describe_table' do
    context 'when nested' do
      before do
        subject.execute <<~SQL
          CREATE TABLE rspec (
            date Date,
            id UInt32,
            json Nested (uid UInt32)
          ) ENGINE = MergeTree(date, (id, date), 8192)
        SQL
      end

      let(:expectation) do
        [
          {'name' =>'date', 'type' =>'Date', 'default_type' =>'', 'default_expression' =>'', 'comment' =>'', 'codec_expression' =>'', 'ttl_expression' =>''},
          {'name' =>'id', 'type' =>'UInt32', 'default_type' =>'', 'default_expression' =>'', 'comment' =>'', 'codec_expression' =>'', 'ttl_expression' =>''},
          {'name' =>'json.uid', 'type' =>'Array(UInt32)', 'default_type' =>'', 'default_expression' =>'', 'comment' =>'', 'codec_expression' =>'', 'ttl_expression' =>''}
        ]
      end

      it 'works' do
        expect(subject.describe_table('rspec').to_a).to eq(expectation)
      end
    end

    context 'when table not exists' do
      it 'errors' do
        expect { subject.describe_table('foo') }.to raise_error(ClickHouse::DbException)
      end
    end
  end

  describe '#drop_table' do
    context 'when not exists' do
      it 'errors' do
        expect { subject.drop_table('foo') }.to raise_error(ClickHouse::DbException)
      end
    end

    context 'when if exists' do
      it 'works' do
        expect(subject.drop_table('foo', if_exists: true)).to eq(true)
      end
    end

    context 'when default' do
      before do
        subject.execute <<~SQL
          CREATE TABLE rspec (date Date, id UInt32) ENGINE = MergeTree(date, (id, date), 8192)
        SQL
      end

      it 'works' do
        expect(subject.drop_table('rspec')).to eq(true)
      end
    end
  end

  describe '#truncate_table' do
    context 'when table exists' do
      before do
        subject.execute <<~SQL
          CREATE TABLE rspec(id Int64) ENGINE TinyLog
        SQL

        subject.insert('rspec', columns: %i[id], values: [[1]])
      end

      it 'works' do
        expect { subject.truncate_table('rspec') }.to change { subject.select_value('SELECT COUNT(*) from rspec') }.from(1).to(0)
      end
    end

    context 'when table not exists' do
      it 'errors' do
        expect { subject.truncate_table('rspec') }.to raise_error(ClickHouse::DbException)
      end
    end

    context 'when if exists' do
      it 'works' do
        expect(subject.truncate_table('rspec', if_exists: true)).to eq(true)
      end
    end
  end

  describe '#truncate_tables' do
    before do
      subject.execute <<~SQL
        CREATE TABLE rspec_1(id Int64) ENGINE TinyLog
      SQL

      subject.execute <<~SQL
        CREATE TABLE rspec_2(id Int64) ENGINE TinyLog
      SQL

      subject.insert('rspec_1', columns: %i[id], values: [[1]])
      subject.insert('rspec_2', columns: %i[id], values: [[1]])
    end

    it 'works' do
      sql = <<~SQL
        SELECT (SELECT COUNT(*) FROM rspec_1) + (SELECT COUNT(*) FROM rspec_2)
      SQL

      expect { subject.truncate_tables }.to change { subject.select_value(sql) }.from(2).to(0)
    end
  end

  describe '#rename_table' do
    before do
      subject.execute <<~SQL
        CREATE TABLE bar(id Int64) ENGINE TinyLog
      SQL

      subject.execute <<~SQL
        CREATE TABLE foo(id Int64) ENGINE TinyLog
      SQL
    end

    context 'when 1 to 1' do
      it 'works' do
        expect { subject.rename_table('bar', 'baz') }.to change { subject.tables }.from(%w[bar foo]).to(%w[baz foo])
      end
    end

    context 'when many to many' do
      it 'works' do
        expect { subject.rename_table(%w[bar foo], %w[baz foz]) }.to change { subject.tables }.from(%w[bar foo]).to(%w[baz foz])
      end
    end

    context 'when incorrect arity' do
      it 'errors' do
        expect { subject.rename_table(%w[bar foo], %w[baz]) }.to raise_error(ClickHouse::StatementException)
      end
    end
  end
end
