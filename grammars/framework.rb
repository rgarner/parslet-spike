module FrameworkDefinition
  class TreeNode
    include Enumerable
    attr_reader :text, :offset, :elements

    def initialize(text, offset, elements = [])
      @text = text
      @offset = offset
      @elements = elements
    end

    def each(&block)
      @elements.each(&block)
    end
  end

  class TreeNode1 < TreeNode
    attr_reader :__, :framework_identifier, :framework_block

    def initialize(text, offset, elements)
      super
      @__ = elements[7]
      @framework_identifier = elements[2]
      @framework_block = elements[6]
    end
  end

  class TreeNode2 < TreeNode
    attr_reader :metadata_pair

    def initialize(text, offset, elements)
      super
      @metadata_pair = elements[0]
    end
  end

  class TreeNode3 < TreeNode
    attr_reader :pascal_identifier, :__, :string

    def initialize(text, offset, elements)
      super
      @pascal_identifier = elements[0]
      @__ = elements[1]
      @string = elements[2]
    end
  end

  class TreeNode4 < TreeNode
    attr_reader :value

    def initialize(text, offset, elements)
      super
      @value = elements[1]
    end
  end

  class TreeNode5 < TreeNode
    attr_reader :value

    def initialize(text, offset, elements)
      super
      @value = elements[1]
    end
  end

  ParseError = Class.new(StandardError)

  FAILURE = Object.new

  module Grammar
    def _read_definition
      address0, index0 = FAILURE, @offset
      cached = @cache[:definition][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1, elements0 = @offset, []
      address1 = FAILURE
      chunk0 = nil
      if @offset < @input_size
        chunk0 = @input[@offset...@offset + 9]
      end
      if chunk0 == "Framework"
        address1 = TreeNode.new(@input[@offset...@offset + 9], @offset)
        @offset = @offset + 9
      else
        address1 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "\"Framework\""
        end
      end
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        address2 = _read___
        unless address2 == FAILURE
          elements0 << address2
          address3 = FAILURE
          address3 = _read_framework_identifier
          unless address3 == FAILURE
            elements0 << address3
            address4 = FAILURE
            address4 = _read___
            unless address4 == FAILURE
              elements0 << address4
              address5 = FAILURE
              chunk1 = nil
              if @offset < @input_size
                chunk1 = @input[@offset...@offset + 1]
              end
              if chunk1 == "{"
                address5 = TreeNode.new(@input[@offset...@offset + 1], @offset)
                @offset = @offset + 1
              else
                address5 = FAILURE
                if @offset > @failure
                  @failure = @offset
                  @expected = []
                end
                if @offset == @failure
                  @expected << "\"{\""
                end
              end
              unless address5 == FAILURE
                elements0 << address5
                address6 = FAILURE
                address6 = _read___
                unless address6 == FAILURE
                  elements0 << address6
                  address7 = FAILURE
                  address7 = _read_framework_block
                  unless address7 == FAILURE
                    elements0 << address7
                    address8 = FAILURE
                    address8 = _read___
                    unless address8 == FAILURE
                      elements0 << address8
                      address9 = FAILURE
                      chunk2 = nil
                      if @offset < @input_size
                        chunk2 = @input[@offset...@offset + 1]
                      end
                      if chunk2 == "}"
                        address9 = TreeNode.new(@input[@offset...@offset + 1], @offset)
                        @offset = @offset + 1
                      else
                        address9 = FAILURE
                        if @offset > @failure
                          @failure = @offset
                          @expected = []
                        end
                        if @offset == @failure
                          @expected << "\"}\""
                        end
                      end
                      unless address9 == FAILURE
                        elements0 << address9
                      else
                        elements0 = nil
                        @offset = index1
                      end
                    else
                      elements0 = nil
                      @offset = index1
                    end
                  else
                    elements0 = nil
                    @offset = index1
                  end
                else
                  elements0 = nil
                  @offset = index1
                end
              else
                elements0 = nil
                @offset = index1
              end
            else
              elements0 = nil
              @offset = index1
            end
          else
            elements0 = nil
            @offset = index1
          end
        else
          elements0 = nil
          @offset = index1
        end
      else
        elements0 = nil
        @offset = index1
      end
      if elements0.nil?
        address0 = FAILURE
      else
        address0 = TreeNode1.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      end
      @cache[:definition][index0] = [address0, @offset]
      return address0
    end

    def _read_framework_block
      address0, index0 = FAILURE, @offset
      cached = @cache[:framework_block][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      address0 = _read_metadata_list
      @cache[:framework_block][index0] = [address0, @offset]
      return address0
    end

    def _read_metadata_list
      address0, index0 = FAILURE, @offset
      cached = @cache[:metadata_list][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      remaining0, index1, elements0, address1 = 0, @offset, [], true
      until address1 == FAILURE
        index2, elements1 = @offset, []
        address2 = FAILURE
        address2 = _read_metadata_pair
        unless address2 == FAILURE
          elements1 << address2
          address3 = FAILURE
          index3 = @offset
          address3 = _read___
          if address3 == FAILURE
            address3 = TreeNode.new(@input[index3...index3], index3)
            @offset = index3
          end
          unless address3 == FAILURE
            elements1 << address3
          else
            elements1 = nil
            @offset = index2
          end
        else
          elements1 = nil
          @offset = index2
        end
        if elements1.nil?
          address1 = FAILURE
        else
          address1 = TreeNode2.new(@input[index2...@offset], index2, elements1)
          @offset = @offset
        end
        unless address1 == FAILURE
          elements0 << address1
          remaining0 -= 1
        end
      end
      if remaining0 <= 0
        address0 = TreeNode.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      else
        address0 = FAILURE
      end
      @cache[:metadata_list][index0] = [address0, @offset]
      return address0
    end

    def _read_metadata_pair
      address0, index0 = FAILURE, @offset
      cached = @cache[:metadata_pair][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1, elements0 = @offset, []
      address1 = FAILURE
      address1 = _read_pascal_identifier
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        address2 = _read___
        unless address2 == FAILURE
          elements0 << address2
          address3 = FAILURE
          address3 = _read_string
          unless address3 == FAILURE
            elements0 << address3
          else
            elements0 = nil
            @offset = index1
          end
        else
          elements0 = nil
          @offset = index1
        end
      else
        elements0 = nil
        @offset = index1
      end
      if elements0.nil?
        address0 = FAILURE
      else
        address0 = TreeNode3.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      end
      @cache[:metadata_pair][index0] = [address0, @offset]
      return address0
    end

    def _read___
      address0, index0 = FAILURE, @offset
      cached = @cache[:__][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      chunk0 = nil
      if @offset < @input_size
        chunk0 = @input[@offset...@offset + 1]
      end
      if chunk0 =~ /\A[\s\n]/
        address0 = TreeNode.new(@input[@offset...@offset + 1], @offset)
        @offset = @offset + 1
      else
        address0 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "[\\s\\n]"
        end
      end
      @cache[:__][index0] = [address0, @offset]
      return address0
    end

    def _read_string
      address0, index0 = FAILURE, @offset
      cached = @cache[:string][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1, elements0 = @offset, []
      address1 = FAILURE
      chunk0 = nil
      if @offset < @input_size
        chunk0 = @input[@offset...@offset + 1]
      end
      if chunk0 == "'"
        address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
        @offset = @offset + 1
      else
        address1 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "\"'\""
        end
      end
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        remaining0, index2, elements1, address3 = 0, @offset, [], true
        until address3 == FAILURE
          chunk1 = nil
          if @offset < @input_size
            chunk1 = @input[@offset...@offset + 1]
          end
          if chunk1 =~ /\A[^']/
            address3 = TreeNode.new(@input[@offset...@offset + 1], @offset)
            @offset = @offset + 1
          else
            address3 = FAILURE
            if @offset > @failure
              @failure = @offset
              @expected = []
            end
            if @offset == @failure
              @expected << "[^']"
            end
          end
          unless address3 == FAILURE
            elements1 << address3
            remaining0 -= 1
          end
        end
        if remaining0 <= 0
          address2 = TreeNode.new(@input[index2...@offset], index2, elements1)
          @offset = @offset
        else
          address2 = FAILURE
        end
        unless address2 == FAILURE
          elements0 << address2
          address4 = FAILURE
          chunk2 = nil
          if @offset < @input_size
            chunk2 = @input[@offset...@offset + 1]
          end
          if chunk2 == "'"
            address4 = TreeNode.new(@input[@offset...@offset + 1], @offset)
            @offset = @offset + 1
          else
            address4 = FAILURE
            if @offset > @failure
              @failure = @offset
              @expected = []
            end
            if @offset == @failure
              @expected << "\"'\""
            end
          end
          unless address4 == FAILURE
            elements0 << address4
          else
            elements0 = nil
            @offset = index1
          end
        else
          elements0 = nil
          @offset = index1
        end
      else
        elements0 = nil
        @offset = index1
      end
      if elements0.nil?
        address0 = FAILURE
      else
        address0 = @actions.make_string(@input, index1, @offset, elements0)
        @offset = @offset
      end
      @cache[:string][index0] = [address0, @offset]
      return address0
    end

    def _read_value
      address0, index0 = FAILURE, @offset
      cached = @cache[:value][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1 = @offset
      address0 = _read_list
      if address0 == FAILURE
        @offset = index1
        address0 = _read_number
        if address0 == FAILURE
          @offset = index1
        end
      end
      @cache[:value][index0] = [address0, @offset]
      return address0
    end

    def _read_list
      address0, index0 = FAILURE, @offset
      cached = @cache[:list][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1, elements0 = @offset, []
      address1 = FAILURE
      chunk0 = nil
      if @offset < @input_size
        chunk0 = @input[@offset...@offset + 1]
      end
      if chunk0 == "["
        address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
        @offset = @offset + 1
      else
        address1 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "\"[\""
        end
      end
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        address2 = _read_value
        unless address2 == FAILURE
          elements0 << address2
          address3 = FAILURE
          remaining0, index2, elements1, address4 = 0, @offset, [], true
          until address4 == FAILURE
            index3, elements2 = @offset, []
            address5 = FAILURE
            chunk1 = nil
            if @offset < @input_size
              chunk1 = @input[@offset...@offset + 1]
            end
            if chunk1 == ","
              address5 = TreeNode.new(@input[@offset...@offset + 1], @offset)
              @offset = @offset + 1
            else
              address5 = FAILURE
              if @offset > @failure
                @failure = @offset
                @expected = []
              end
              if @offset == @failure
                @expected << "\",\""
              end
            end
            unless address5 == FAILURE
              elements2 << address5
              address6 = FAILURE
              address6 = _read_value
              unless address6 == FAILURE
                elements2 << address6
              else
                elements2 = nil
                @offset = index3
              end
            else
              elements2 = nil
              @offset = index3
            end
            if elements2.nil?
              address4 = FAILURE
            else
              address4 = TreeNode5.new(@input[index3...@offset], index3, elements2)
              @offset = @offset
            end
            unless address4 == FAILURE
              elements1 << address4
              remaining0 -= 1
            end
          end
          if remaining0 <= 0
            address3 = TreeNode.new(@input[index2...@offset], index2, elements1)
            @offset = @offset
          else
            address3 = FAILURE
          end
          unless address3 == FAILURE
            elements0 << address3
            address7 = FAILURE
            chunk2 = nil
            if @offset < @input_size
              chunk2 = @input[@offset...@offset + 1]
            end
            if chunk2 == "]"
              address7 = TreeNode.new(@input[@offset...@offset + 1], @offset)
              @offset = @offset + 1
            else
              address7 = FAILURE
              if @offset > @failure
                @failure = @offset
                @expected = []
              end
              if @offset == @failure
                @expected << "\"]\""
              end
            end
            unless address7 == FAILURE
              elements0 << address7
            else
              elements0 = nil
              @offset = index1
            end
          else
            elements0 = nil
            @offset = index1
          end
        else
          elements0 = nil
          @offset = index1
        end
      else
        elements0 = nil
        @offset = index1
      end
      if elements0.nil?
        address0 = FAILURE
      else
        address0 = @actions.make_list(@input, index1, @offset, elements0)
        @offset = @offset
      end
      @cache[:list][index0] = [address0, @offset]
      return address0
    end

    def _read_number
      address0, index0 = FAILURE, @offset
      cached = @cache[:number][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      remaining0, index1, elements0, address1 = 1, @offset, [], true
      until address1 == FAILURE
        chunk0 = nil
        if @offset < @input_size
          chunk0 = @input[@offset...@offset + 1]
        end
        if chunk0 =~ /\A[0-9]/
          address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
          @offset = @offset + 1
        else
          address1 = FAILURE
          if @offset > @failure
            @failure = @offset
            @expected = []
          end
          if @offset == @failure
            @expected << "[0-9]"
          end
        end
        unless address1 == FAILURE
          elements0 << address1
          remaining0 -= 1
        end
      end
      if remaining0 <= 0
        address0 = @actions.make_number(@input, index1, @offset, elements0)
        @offset = @offset
      else
        address0 = FAILURE
      end
      @cache[:number][index0] = [address0, @offset]
      return address0
    end

    def _read_framework_identifier
      address0, index0 = FAILURE, @offset
      cached = @cache[:framework_identifier][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      remaining0, index1, elements0, address1 = 1, @offset, [], true
      until address1 == FAILURE
        chunk0 = nil
        if @offset < @input_size
          chunk0 = @input[@offset...@offset + 1]
        end
        if chunk0 =~ /\A[A-Z0-9\/]/
          address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
          @offset = @offset + 1
        else
          address1 = FAILURE
          if @offset > @failure
            @failure = @offset
            @expected = []
          end
          if @offset == @failure
            @expected << "[A-Z0-9/]"
          end
        end
        unless address1 == FAILURE
          elements0 << address1
          remaining0 -= 1
        end
      end
      if remaining0 <= 0
        address0 = TreeNode.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      else
        address0 = FAILURE
      end
      @cache[:framework_identifier][index0] = [address0, @offset]
      return address0
    end

    def _read_pascal_identifier
      address0, index0 = FAILURE, @offset
      cached = @cache[:pascal_identifier][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      remaining0, index1, elements0, address1 = 1, @offset, [], true
      until address1 == FAILURE
        index2, elements1 = @offset, []
        address2 = FAILURE
        chunk0 = nil
        if @offset < @input_size
          chunk0 = @input[@offset...@offset + 1]
        end
        if chunk0 =~ /\A[A-Z]/
          address2 = TreeNode.new(@input[@offset...@offset + 1], @offset)
          @offset = @offset + 1
        else
          address2 = FAILURE
          if @offset > @failure
            @failure = @offset
            @expected = []
          end
          if @offset == @failure
            @expected << "[A-Z]"
          end
        end
        unless address2 == FAILURE
          elements1 << address2
          address3 = FAILURE
          chunk1 = nil
          if @offset < @input_size
            chunk1 = @input[@offset...@offset + 1]
          end
          if chunk1 =~ /\A[a-z0-9]/
            address3 = TreeNode.new(@input[@offset...@offset + 1], @offset)
            @offset = @offset + 1
          else
            address3 = FAILURE
            if @offset > @failure
              @failure = @offset
              @expected = []
            end
            if @offset == @failure
              @expected << "[a-z0-9]"
            end
          end
          unless address3 == FAILURE
            elements1 << address3
          else
            elements1 = nil
            @offset = index2
          end
        else
          elements1 = nil
          @offset = index2
        end
        if elements1.nil?
          address1 = FAILURE
        else
          address1 = TreeNode.new(@input[index2...@offset], index2, elements1)
          @offset = @offset
        end
        unless address1 == FAILURE
          elements0 << address1
          remaining0 -= 1
        end
      end
      if remaining0 <= 0
        address0 = TreeNode.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      else
        address0 = FAILURE
      end
      @cache[:pascal_identifier][index0] = [address0, @offset]
      return address0
    end
  end

  class Parser
    include Grammar

    def initialize(input, actions, types)
      @input = input
      @input_size = input.size
      @actions = actions
      @types = types
      @offset = 0
      @cache = Hash.new { |h,k| h[k] = {} }
      @failure = 0
      @expected = []
    end

    def parse
      tree = _read_definition
      if tree != FAILURE and @offset == @input_size
        return tree
      end
      if @expected.empty?
        @failure = @offset
        @expected << "<EOF>"
      end
      raise ParseError, Parser.format_error(@input, @failure, @expected)
    end

    def self.format_error(input, offset, expected)
      lines, line_no, position = input.split(/\n/), 0, 0
      while position <= offset
        position += lines[line_no].size + 1
        line_no += 1
      end
      message, line = "Line #{line_no}: expected #{expected * ", "}\n", lines[line_no - 1]
      message += "#{line}\n"
      position -= line.size + 1
      message += " " * (offset - position)
      return message + "^"
    end
  end

  def self.parse(input, options = {})
    parser = Parser.new(input, options[:actions], options[:types])
    parser.parse
  end
end
