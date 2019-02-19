module URL
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
    attr_reader :scheme, :host, :pathname, :search

    def initialize(text, offset, elements)
      super
      @scheme = elements[0]
      @host = elements[2]
      @pathname = elements[3]
      @search = elements[4]
    end
  end

  class TreeNode2 < TreeNode
    attr_reader :hostname

    def initialize(text, offset, elements)
      super
      @hostname = elements[0]
    end
  end

  class TreeNode3 < TreeNode
    attr_reader :segment

    def initialize(text, offset, elements)
      super
      @segment = elements[0]
    end
  end

  class TreeNode4 < TreeNode
    attr_reader :segment

    def initialize(text, offset, elements)
      super
      @segment = elements[1]
    end
  end

  class TreeNode5 < TreeNode
    attr_reader :query

    def initialize(text, offset, elements)
      super
      @query = elements[1]
    end
  end

  ParseError = Class.new(StandardError)

  FAILURE = Object.new

  module Grammar
    def _read_url
      address0, index0 = FAILURE, @offset
      cached = @cache[:url][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1, elements0 = @offset, []
      address1 = FAILURE
      address1 = _read_scheme
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        chunk0 = nil
        if @offset < @input_size
          chunk0 = @input[@offset...@offset + 3]
        end
        if chunk0 == "://"
          address2 = TreeNode.new(@input[@offset...@offset + 3], @offset)
          @offset = @offset + 3
        else
          address2 = FAILURE
          if @offset > @failure
            @failure = @offset
            @expected = []
          end
          if @offset == @failure
            @expected << "\"://\""
          end
        end
        unless address2 == FAILURE
          elements0 << address2
          address3 = FAILURE
          address3 = _read_host
          unless address3 == FAILURE
            elements0 << address3
            address4 = FAILURE
            address4 = _read_pathname
            unless address4 == FAILURE
              elements0 << address4
              address5 = FAILURE
              address5 = _read_search
              unless address5 == FAILURE
                elements0 << address5
                address6 = FAILURE
                index2 = @offset
                address6 = _read_hash
                if address6 == FAILURE
                  address6 = TreeNode.new(@input[index2...index2], index2)
                  @offset = index2
                end
                unless address6 == FAILURE
                  elements0 << address6
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
      @cache[:url][index0] = [address0, @offset]
      return address0
    end

    def _read_scheme
      address0, index0 = FAILURE, @offset
      cached = @cache[:scheme][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1, elements0 = @offset, []
      address1 = FAILURE
      chunk0 = nil
      if @offset < @input_size
        chunk0 = @input[@offset...@offset + 4]
      end
      if chunk0 == "http"
        address1 = TreeNode.new(@input[@offset...@offset + 4], @offset)
        @offset = @offset + 4
      else
        address1 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "\"http\""
        end
      end
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        index2 = @offset
        chunk1 = nil
        if @offset < @input_size
          chunk1 = @input[@offset...@offset + 1]
        end
        if chunk1 == "s"
          address2 = TreeNode.new(@input[@offset...@offset + 1], @offset)
          @offset = @offset + 1
        else
          address2 = FAILURE
          if @offset > @failure
            @failure = @offset
            @expected = []
          end
          if @offset == @failure
            @expected << "\"s\""
          end
        end
        if address2 == FAILURE
          address2 = TreeNode.new(@input[index2...index2], index2)
          @offset = index2
        end
        unless address2 == FAILURE
          elements0 << address2
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
        address0 = TreeNode.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      end
      @cache[:scheme][index0] = [address0, @offset]
      return address0
    end

    def _read_host
      address0, index0 = FAILURE, @offset
      cached = @cache[:host][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1, elements0 = @offset, []
      address1 = FAILURE
      address1 = _read_hostname
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        index2 = @offset
        address2 = _read_port
        if address2 == FAILURE
          address2 = TreeNode.new(@input[index2...index2], index2)
          @offset = index2
        end
        unless address2 == FAILURE
          elements0 << address2
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
        address0 = TreeNode2.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      end
      @cache[:host][index0] = [address0, @offset]
      return address0
    end

    def _read_hostname
      address0, index0 = FAILURE, @offset
      cached = @cache[:hostname][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1, elements0 = @offset, []
      address1 = FAILURE
      address1 = _read_segment
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        remaining0, index2, elements1, address3 = 0, @offset, [], true
        until address3 == FAILURE
          index3, elements2 = @offset, []
          address4 = FAILURE
          chunk0 = nil
          if @offset < @input_size
            chunk0 = @input[@offset...@offset + 1]
          end
          if chunk0 == "."
            address4 = TreeNode.new(@input[@offset...@offset + 1], @offset)
            @offset = @offset + 1
          else
            address4 = FAILURE
            if @offset > @failure
              @failure = @offset
              @expected = []
            end
            if @offset == @failure
              @expected << "\".\""
            end
          end
          unless address4 == FAILURE
            elements2 << address4
            address5 = FAILURE
            address5 = _read_segment
            unless address5 == FAILURE
              elements2 << address5
            else
              elements2 = nil
              @offset = index3
            end
          else
            elements2 = nil
            @offset = index3
          end
          if elements2.nil?
            address3 = FAILURE
          else
            address3 = TreeNode4.new(@input[index3...@offset], index3, elements2)
            @offset = @offset
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
      @cache[:hostname][index0] = [address0, @offset]
      return address0
    end

    def _read_segment
      address0, index0 = FAILURE, @offset
      cached = @cache[:segment][index0]
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
        if chunk0 =~ /\A[a-z0-9-]/
          address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
          @offset = @offset + 1
        else
          address1 = FAILURE
          if @offset > @failure
            @failure = @offset
            @expected = []
          end
          if @offset == @failure
            @expected << "[a-z0-9-]"
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
      @cache[:segment][index0] = [address0, @offset]
      return address0
    end

    def _read_port
      address0, index0 = FAILURE, @offset
      cached = @cache[:port][index0]
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
      if chunk0 == ":"
        address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
        @offset = @offset + 1
      else
        address1 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "\":\""
        end
      end
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        remaining0, index2, elements1, address3 = 1, @offset, [], true
        until address3 == FAILURE
          chunk1 = nil
          if @offset < @input_size
            chunk1 = @input[@offset...@offset + 1]
          end
          if chunk1 =~ /\A[0-9]/
            address3 = TreeNode.new(@input[@offset...@offset + 1], @offset)
            @offset = @offset + 1
          else
            address3 = FAILURE
            if @offset > @failure
              @failure = @offset
              @expected = []
            end
            if @offset == @failure
              @expected << "[0-9]"
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
        address0 = TreeNode.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      end
      @cache[:port][index0] = [address0, @offset]
      return address0
    end

    def _read_pathname
      address0, index0 = FAILURE, @offset
      cached = @cache[:pathname][index0]
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
      if chunk0 == "/"
        address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
        @offset = @offset + 1
      else
        address1 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "\"/\""
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
          if chunk1 =~ /\A[^ ?]/
            address3 = TreeNode.new(@input[@offset...@offset + 1], @offset)
            @offset = @offset + 1
          else
            address3 = FAILURE
            if @offset > @failure
              @failure = @offset
              @expected = []
            end
            if @offset == @failure
              @expected << "[^ ?]"
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
        address0 = TreeNode.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      end
      @cache[:pathname][index0] = [address0, @offset]
      return address0
    end

    def _read_search
      address0, index0 = FAILURE, @offset
      cached = @cache[:search][index0]
      if cached
        @offset = cached[1]
        return cached[0]
      end
      index1 = @offset
      index2, elements0 = @offset, []
      address1 = FAILURE
      chunk0 = nil
      if @offset < @input_size
        chunk0 = @input[@offset...@offset + 1]
      end
      if chunk0 == "?"
        address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
        @offset = @offset + 1
      else
        address1 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "\"?\""
        end
      end
      unless address1 == FAILURE
        elements0 << address1
        address2 = FAILURE
        remaining0, index3, elements1, address3 = 0, @offset, [], true
        until address3 == FAILURE
          chunk1 = nil
          if @offset < @input_size
            chunk1 = @input[@offset...@offset + 1]
          end
          if chunk1 =~ /\A[^ #]/
            address3 = TreeNode.new(@input[@offset...@offset + 1], @offset)
            @offset = @offset + 1
          else
            address3 = FAILURE
            if @offset > @failure
              @failure = @offset
              @expected = []
            end
            if @offset == @failure
              @expected << "[^ #]"
            end
          end
          unless address3 == FAILURE
            elements1 << address3
            remaining0 -= 1
          end
        end
        if remaining0 <= 0
          address2 = TreeNode.new(@input[index3...@offset], index3, elements1)
          @offset = @offset
        else
          address2 = FAILURE
        end
        unless address2 == FAILURE
          elements0 << address2
        else
          elements0 = nil
          @offset = index2
        end
      else
        elements0 = nil
        @offset = index2
      end
      if elements0.nil?
        address0 = FAILURE
      else
        address0 = TreeNode5.new(@input[index2...@offset], index2, elements0)
        @offset = @offset
      end
      if address0 == FAILURE
        address0 = TreeNode.new(@input[index1...index1], index1)
        @offset = index1
      end
      @cache[:search][index0] = [address0, @offset]
      return address0
    end

    def _read_hash
      address0, index0 = FAILURE, @offset
      cached = @cache[:hash][index0]
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
      if chunk0 == "#"
        address1 = TreeNode.new(@input[@offset...@offset + 1], @offset)
        @offset = @offset + 1
      else
        address1 = FAILURE
        if @offset > @failure
          @failure = @offset
          @expected = []
        end
        if @offset == @failure
          @expected << "\"#\""
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
          if chunk1 =~ /\A[^ ]/
            address3 = TreeNode.new(@input[@offset...@offset + 1], @offset)
            @offset = @offset + 1
          else
            address3 = FAILURE
            if @offset > @failure
              @failure = @offset
              @expected = []
            end
            if @offset == @failure
              @expected << "[^ ]"
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
        address0 = TreeNode.new(@input[index1...@offset], index1, elements0)
        @offset = @offset
      end
      @cache[:hash][index0] = [address0, @offset]
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
      tree = _read_url
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
