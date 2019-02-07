require 'framework/definition/transpiler'

##
# The transpiler spec is useful but comes at a cost.
# We need a mock ast tree that has been generated from a parser.
# In this case we've copied and pasted some of that output, but
# it can fall out of sync with the main parser easily.
#
# In a real-world development we might flesh out language_spec
# a lot more instead. That's an integration test, but it would
# be a lot faster to iterate by changing elements of FDL and
# not trying to replicate a whole AST.
describe Framework::Definition::Transpiler do
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
            { field: 'TotalValue', from: 'Total Spend', type: :string },
            { field: 'Is cromulent', type: :boolean }
          ],
        invoice_fields: [
          { field: 'TotalValue', from: 'Total Spend', type: :string },
          { field: 'CustomerURN', from: 'Customer URN', type: :string },
          { field: 'LotNumber', from: 'Tier Number', type: :string },
          { field: 'ServiceType', from: 'Service Type', type: :string },
          { field: 'SubType', from: 'Sub Type', type: :string },
          { type: :decimal, field: 'Additional8', from: 'Somewhere' },
          { type: :decimal, from: 'Price per Unit', optional: 'optional' },
          { type: :decimal, from: 'Invoice Line Product / Service Grouping' }
        ]
      }
    }
  }

  subject(:generated) do
    Framework::Definition::Transpiler.new(ast).transpile
  end

  it 'is an anonymous class' do
    expect(generated.class).to eql(Class)
  end

  describe 'the metadata' do
    it 'knows its name' do
      expect(generated.framework_name).to eql(ast[:name])
    end
    it 'knows its short name' do
      expect(generated.framework_short_name).to eql(ast[:framework_short_name])
    end
  end

  describe 'the Invoices nested class' do
    subject(:invoices_class) { generated::Invoices }

    it { is_expected.to be < Framework::Definition::EntryData }

    it 'has a model_name' do
      expect(invoices_class.model_name).to eql('Invoice')
    end

    it 'has a total_value_field' do
      expect(invoices_class.total_value_field).to eql('Total Spend')
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

      it 'has field types as we told it from the AST hash' do
        expect(invoices_class.attribute_types['Price per Unit']).to be_kind_of(
          ActiveModel::Type::Decimal)
      end

      it 'maps optional fields to allow_nil: true' do
        expect(invoices_class.validators).to include(
          an_object_having_attributes(
            attributes: ['Price per Unit'],
            options: { allow_nil: true }
          )
        )
      end
    end

    context 'there are no invoice fields' do
      before { ast[:entry_data].delete(:invoice_fields) }

      it 'does not generate an Invoices nested class' do
        expect(generated.const_defined?('Invoices')).to be false
      end
    end
  end

  describe 'the Contracts nested class' do
    subject(:contracts_class) { generated::Contracts }

    it { is_expected.to be < Framework::Definition::EntryData }

    it 'has a model_name' do
      expect(contracts_class.model_name).to eql('Contract')
    end

    it 'has a total_value_field' do
      expect(contracts_class.total_value_field).to eql('Total Spend')
    end

    describe 'the fields' do
      let(:entry) { double 'SubmissionEntry', data: {} }

      subject(:contracts) { contracts_class.new(entry) }

      it 'has some fields' do
        expect(contracts.attributes.length).to eql(
          ast.dig(:entry_data, :contract_fields).length)
      end

      it 'has field types as we told it from the AST hash' do
        expect(contracts_class.attribute_types['Is cromulent']).to be_kind_of(
          ActiveModel::Type::Boolean)
      end
    end

    context 'there are no contract fields' do
      before { ast[:entry_data].delete(:contract_fields) }

      it 'does not generate a Contracts nested class' do
        expect(generated.const_defined?('Contracts')).to be false
      end
    end
  end
end

