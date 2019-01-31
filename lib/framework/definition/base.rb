##
# Base class for a framework definition with metadata methods
class Base
  class << self
    ##
    # E.g. "Rail Legal Services"
    def framework_name(framework_name = nil)
      @framework_name ||= framework_name
    end

    ##
    # E.g. "RM3786"
    def framework_short_name(framework_short_name = nil)
      @framework_short_name ||= framework_short_name
    end

    ##
    # E.g. BigDecimal.new('1.5')
    def management_charge_rate(charge_rate = nil)
      @management_charge_rate ||= charge_rate
    end

    def management_charge(value)
      (value * (management_charge_rate / 100)).truncate(4)
    end

    def for_entry_type(entry_type)
      entry_type == 'invoice' ? self::Invoice : self::Order
    end
  end
end