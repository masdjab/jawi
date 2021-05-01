class ParsingError < Exception
  attr_reader :pos
  def initialize(pos, message)
    @pos = pos
    super("Error at #{@pos}: #{message}")
  end
end


class ExpectedTextException < ParsingError
  attr_reader :expected, :found
  def initialize(pos, expected, found)
    @expected = expected
    @found = found
    puts "ExpectedTextException => pos: #{pos.class}(#{pos})"
    super(pos, "Expected '#{@expected}', found #{@found ? "'#{@found}'" : "nil"} at #{pos}.")
  end
end


class UnexpectedTextException < ParsingError
  attr_reader :text
  def initialize(pos, text)
    @text = text
    super(pos, "Unexpected '#{@text}' at #{pos}.")
  end
end
