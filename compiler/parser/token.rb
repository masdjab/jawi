class Token
  attr_reader :pos, :type, :text
  def initialize(pos, type, text)
    @pos = pos
    @type = type
    @text = text
  end
  def to_s
    "Token(#{@pos}, #{@type.inspect}, #{@text.inspect})"
  end
end
