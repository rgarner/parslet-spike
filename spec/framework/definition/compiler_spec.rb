require 'framework/definition/compiler'

describe Framework::Definition::Compiler do
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
          { type: 'Decimal ', field: 'Additional8', from: 'Somewhere' },
          { type: 'Decimal ', from: 'Price per Unit', optional: 'optional' },
          { type: 'Decimal ', from: 'Invoice Line Product / Service Grouping' }
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

  it 'includes ActiveModel'

  describe 'the Invoices nested class' do
    subject { compiled::Invoices }

    it { is_expected.to be < Framework::Definition::EntryData }

    context 'there are no invoice fields' do
      before { ast[:entry_data].delete(:invoice_fields) }

      it 'does not generate an Invoices nested class' do
        expect { compiled::Invoices }.to raise_error(NameError, /Invoices/)
      end
    end
  end

  describe 'the Contracts nested class' do
    subject { compiled::Contracts }

    it { is_expected.to be < Framework::Definition::EntryData }

    context 'there are no contract fields' do
      before { ast[:entry_data].delete(:contract_fields) }

      it 'does not generate a Contracts nested class' do
        expect { compiled::Contracts }.to raise_error(NameError, /Contracts/)
      end
    end
  end
end

