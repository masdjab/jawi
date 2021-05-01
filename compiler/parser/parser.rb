require_relative 'parsing_const'
require_relative 'parsing_exceptions'
require_relative 'parsed_text'

class Parser
  private
  def initialize(fetcher, pos_info = nil)
    @fetcher = fetcher
    @pos_info = pos_info
  end
  def position_info(pos)
    @pos_info ? @pos_info.get_position_info(pos) : pos
  end
  def expected_text(pos, expected, found)
    ExpectedTextException.new(position_info(pos), expected, found)
  end
  def unexpected_text(pos, text)
    UnexpectedTextException.new(position_info(pos), text)
  end
  def parsed_text(pos, text)
    ParsedText.new(position_info(pos), text)
  end
  def fetch_chars(chars)
    result = ""

    while chars.index(@fetcher.current)
      result << @fetcher.fetch
    end

    result
  end

  public
  def parse
    result = nil

    if @fetcher.has_next?
      anchor = @fetcher.pos
      char = @fetcher.current

      if ParsingConst::WHITESPACES.index(char)
        text = fetch_chars(ParsingConst::WHITESPACES)
      elsif ParsingConst::NUMBERS.index(char)
        text = fetch_chars(ParsingConst::NUMBERS)
      elsif ParsingConst::LETTERS_EXT.index(char)
        text = fetch_chars(ParsingConst::LETTERS_EXT)
      else
        text = @fetcher.fetch
      end

      if text
        result = parsed_text(anchor, text)
      end
    end

    result
  end
end
