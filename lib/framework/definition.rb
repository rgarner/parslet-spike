class Framework
  # Copied from the API project for speed
  module Definition
    class MissingError < StandardError; end

    class << self
      def all
        Framework::Definition.constants
          .reject { |c| c == :Base }
          .map    { |c| Framework::Definition.const_get(c) }
          .select { |c| c.ancestors.include?(Framework::Definition::Base) }
      end

      def [](framework_short_name)
        sanitized_framework_short_name = framework_short_name.tr('/.', '_')
        "Framework::Definition::#{sanitized_framework_short_name}".constantize
      rescue NameError
        raise Framework::Definition::MissingError, %(Please run rails g framework:definition "#{framework_short_name}")
      end
    end

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

    # Require all the framework definitions up-front
    Dir['app/models/framework/definition/*'].each do |definition|
      # `Dir` needs an app-relative path argument, but `require` needs one relative to
      # the $LOAD_PATH. Remove app/models/ to e.g. only `require 'framework/definition/RM1234'`
      relative_definition = Pathname(definition).sub('app/models/', '').sub_ext('').to_s
      require relative_definition
    end
  end
end
