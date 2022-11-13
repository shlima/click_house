RSpec.describe ClickHouse::Ast::Parser do
  let(:expectations) do
    {
      "Int" => 'Int',
      "DateTime('Asia/Istanbul')" => "DateTime('Asia/Istanbul')",
      "Array(Int, String(2))" => "Array(Int,String(2))",
      "Array(Array(Array(Array(Nullable(Int, String)))))" => "Array(Array(Array(Array(Nullable(Int,String)))))",
      "Function(Decimal(1, 2), Map(Decimal(3, 4), Decimal(5, 6)))" => "Function(Decimal(1,2),Map(Decimal(3,4),Decimal(5,6)))",
      "Array(Map(Decimal(1, 2), Decimal(3, 4)))" => "Array(Map(Decimal(1,2),Decimal(3,4)))",
      "Map(Decimal(1, 2), Decimal(3, 4))" => "Map(Decimal(1,2),Decimal(3,4))",
      "Map(Decimal(1,2))" => "Map(Decimal(1,2))",
      "Map(String, Decimal(1,2))" => "Map(String,Decimal(1,2))",
      "Decimal(1,2)" => "Decimal(1,2)",
      "A(1)" => "A(1)",
      "A(1, 2)" => "A(1,2)",
      "A(B(1))" => "A(B(1))",
      "A(B(1), B(2))" => "A(B(1),B(2))",
      "Enum8('hello' = 1, 'world' = 2)" => "Enum8('hello' = 1,'world' = 2)"
    }
  end

  it 'works' do
    expectations.each do |statement, expect|
      expect(described_class.new(statement).parse.to_s).to eq(expect)
    end
  end

  context 'when Array with nested type' do
    subject do
      described_class.new("Array(String(2))").parse
    end

    it 'works' do
      expect(subject.name).to eq('Array')
      expect(subject.arguments).to have_attributes(size: 1)
      expect(subject.arguments.first.name).to eq("String")
      expect(subject.arguments.first.arguments).to have_attributes(size: 1)
      expect(subject.arguments.first.arguments.first.name).to eq("2")
    end
  end

  context 'when space between arguments' do
    subject do
      described_class.new("Foo(10, 'bar')").parse
    end

    it 'works' do
      expect(subject.name).to eq('Foo')
      expect(subject.arguments.map(&:placeholder)).to eq(%w[%d %s])
      expect(subject.arguments.map(&:value)).to eq([10, 'bar'])
    end
  end
end
