require 'framework/definition/compiler'

describe Framework::Definition::Compiler do
  ##
  # An AST produced from calling
  # +Framework::Definition::Parser.new(definition_content).parse+
  let(:ast) {
    {
      framework_short_name: 'CM/OSG/05/3565',
      name: 'Laundry Services - Wave 2',
      management_charge_rate: 0.5e0,
      entry_data: {
        contract_fields:
          [
            { name: 'TotalValue', from: 'Total Spend', type: 'String' }
          ],
        invoice_fields: [
          { name: 'TotalValue', from: 'Total Spend', type: 'String' },
          { name: 'CustomerURN', from: 'Customer URN', type: 'String' },
          { name: 'LotNumber', from: 'Tier Number', type: 'String' },
          { name: 'ServiceType', from: 'Service Type', type: 'String' },
          { name: 'SubType', from: 'Sub Type', type: 'String' },
          { type: 'Decimal', name: 'Additional8', from: 'Somewhere' },
          { type: 'Decimal', from: 'Price per Unit', optional: 'optional' },
          { type: 'Decimal', from: 'Invoice Line Product / Service Grouping' }
        ]
      }
    }
  }

  subject(:compiled) do
    Framework::Definition::Compiler.new(ast).compile
  end

  it 'is an anonymous class' do
    expect(compiled.class).to eql(Class)
  end

  describe 'the metadata' do
    it 'knows its name' do
      expect(compiled.framework_name).to eql(ast[:name])
    end
  end

  describe 'the Invoices nested class' do
    subject(:invoices_class) { compiled::Invoices }

    it { is_expected.to be < Framework::Definition::EntryData }

    it 'has a model_name' do
      expect(invoices_class.model_name).to eql('Invoice')
    end

    it 'passes through the creation of export_mappings' do
      expect(invoices_class.export_mappings['Total Spend']).to eql('TotalValue')
    end

    describe 'the fields' do
      let(:entry) { double 'SubmissionEntry', data: {} }

      subject(:invoices) { invoices_class.new(entry) }

      it 'has some fields' do
        expect(invoices.attributes.length).to eql(
          ast.dig(:entry_data, :invoice_fields).length)
      end
    end

    context 'there are no invoice fields' do
      before { ast[:entry_data].delete(:invoice_fields) }

      it 'does not generate an Invoices nested class' do
        expect(compiled.const_defined?('Invoices')).to be false
      end
    end
  end

  describe 'the Contracts nested class' do
    subject(:contracts_class) { compiled::Contracts }

    it { is_expected.to be < Framework::Definition::EntryData }

    it 'has a model_name' do
      expect(contracts_class.model_name).to eql('Contract')
    end

    describe 'the fields' do
      let(:entry) { double 'SubmissionEntry', data: {} }

      subject(:contracts) { contracts_class.new(entry) }

      it 'has some fields' do
        expect(contracts.attributes.length).to eql(
          ast.dig(:entry_data, :contract_fields).length)
      end
    end

    context 'there are no contract fields' do
      before { ast[:entry_data].delete(:contract_fields) }

      it 'does not generate a Contracts nested class' do
        expect(compiled.const_defined?('Contracts')).to be false
      end
    end
  end
end

