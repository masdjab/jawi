class ParsedText
  attr_reader :pos, :text
  def initialize(pos, text)
    @pos = pos
    @text = text
  end
end
