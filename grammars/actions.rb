class Actions
  def make_map(input, start, _end, elements)
    {elements[1] => elements[3]}
  end

  def make_string(input, start, _end, elements)
    elements[1].text
  end

  def make_list(input, start, _end, elements)
    list = [elements[1]]
    elements[2].each { |el| list << el.value }
    list
  end

  def make_number(input, start, _end, elements)
    input[start..._end].to_i(10)
  end
end