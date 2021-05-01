require_relative 'parsing_const'
require_relative 'token'


class Tokenizer
  PUNCTUATION_TYPES = {
    ","   => :comma,
    ":"   => :colon,
    ";"   => :semicolon,
    "("   => :lbrk,
    ")"   => :rbrk,
    "["   => :lsbrk,
    "]"   => :rsbrk,
    "{"   => :lcbrk,
    "}"   => :rcbrk,
    "\\"  => :bslash,
    "?"   => :question,
    "!"   => :exclamation,
    "@"   => :at,
    "~"   => :tilde,
    "`"   => :bquote,
    "$"   => :dollar,
    "%"   => :percent,
    "^"   => :xor
  }
  
  
  private
  def initialize(fetcher, position_info_provider = nil)
    @fetcher = fetcher
    @position_info_provider = position_info_provider
  end
  def position_info(pos)
    @position_info_provider ? @position_info_provider.get_position_info(pos) : pos
  end
  def expected_text(pos, expected, found)
    ExpectedTextException.new(position_info(pos).tap{|x|puts "expected_text => #{pos.inspect}"}, expected, found)
  end
  def unexpected_text(pos, text)
    UnexpectedTextException.new(position_info(pos), text)
  end
  def fetch_chars(chars)
    result = ""

    while !@fetcher.current.nil? && (chars.index(@fetcher.current))
      result << @fetcher.fetch
    end

    result
  end
  def fetch_whitespace(pos_info)
    Token.new(pos_info, :whitespace, fetch_chars(ParsingConst::WHITESPACES))
  end
  def fetch_linefeed(pos_info)
    lnfd = 13.chr + 10.chr
    type = nil
    char = @fetcher.current
    text = ""

    if char == lnfd[0]
      text << @fetcher.fetch

      if @fetcher.current == lnfd[1]
        text << @fetcher.fetch
        type = :crlf
      else
        type = :cr
      end
    elsif char == lnfd[1]
      text << @fetcher.fetch
      type = :lf
    end

    Token.new(pos_info, type, text)
  end
  def fetch_comment(pos_info)
    text = @fetcher.fetch

    while char = @fetcher.current
      if (13.chr + 10.chr).index(char)
        break
      else
        text << @fetcher.fetch
      end
    end

    Token.new(pos_info, :comment, text)
  end
  def fetch_identifier(pos_info)
    Token.new(pos_info, :identifier, fetch_chars(ParsingConst::IDENTIFIERS))
  end
  def fetch_string(pos_info)
    result = ""
    quote = nil
    escape = false
    
    while @fetcher.has_next?
      result << char = @fetcher.fetch

      if ParsingConst::QUOTES.index(char)
        if !quote.nil? && !escape && (char == quote)
          break
        end
        if quote.nil?
          quote = char
        end
      end
      
      if !@fetcher.has_next? && ((char != quote) || escape)
        raise expected_text(@fetcher.pos, quote, nil)
      end
      
      escape = char == "\\"
    end
    
    Token.new(pos_info, :string, result)
  end
  def fetch_number(pos_info)
    result = ""

    while char = @fetcher.current
      if ParsingConst::NUMBERS.index(char)
        result << @fetcher.fetch
      elsif char == "."
        if !result.index(".").nil?
          raise unexpected_text(@fetcher.pos, char)
        elsif result[0..1] == "0x"
          raise unexpected_text(@fetcher.pos, char)
        elsif @fetcher.next.nil?
          raise expected_text(@fetcher.pos + 1, 'number', nil)
        elsif !ParsingConst::NUMBERS.index(next_char = @fetcher.next).nil?
          result << @fetcher.fetch
        else
          break
        end
      elsif char == "x"
        if result != "0"
          raise unexpected_text(@fetcher.pos, char)
        elsif @fetcher.next.nil?
          raise expected_text(@fetcher.pos + 1, 'hex number', nil)
        elsif ParsingConst::HEX_NUMS.index(next_char = @fetcher.next).nil?
          raise expected_text(@fetcher.pos + 1, 'hex number', next_char)
        else
          result << @fetcher.fetch
        end
      elsif "abcdef".index(char.downcase)
        if (result.length >= 2) && (result[0..1].downcase == "0x")
          result << @fetcher.fetch
        else
          raise unexpected_text(@fetcher.pos, char)
        end
      elsif ParsingConst::IDENTIFIERS.index(char.downcase)
        raise unexpected_text(@fetcher.pos, char)
      else
        break
      end
    end

    Token.new(pos_info, :number, result)
  end
  def fetch_plus(pos_info)
    text = @fetcher.fetch
    type = :plus

    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :plus_assign
    end

    Token.new(pos_info, type, text)
  end
  def fetch_minus(pos_info)
    text = @fetcher.fetch
    type = :minus

    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :minus_assign
    end

    Token.new(pos_info, type, text)
  end
  def fetch_star(pos_info)
    text = @fetcher.fetch
    type = :star

    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :star_assign
    end

    Token.new(pos_info, type, text)
  end
  def fetch_slash(pos_info)
    text = @fetcher.fetch
    type = :slash

    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :slash_assign
    end

    Token.new(pos_info, type, text)
  end
  def fetch_not(pos_info)
    text = @fetcher.fetch
    type = :exclamation

    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :not_equal
    end

    Token.new(pos_info, type, text)
  end
  def fetch_and(pos_info)
    text = @fetcher.fetch
    type = :and
    
    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :and_assign
    elsif @fetcher.current == "&"
      text << @fetcher.fetch
      type = :and2
    end
    
    Token.new(pos_info, type, text)
  end
  def fetch_or(pos_info)
    text = @fetcher.fetch
    type = :or
    
    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :or_assign
    elsif @fetcher.current == "|"
      text << @fetcher.fetch
      type = :or2
    end
    
    Token.new(pos_info, type, text)
  end
  def fetch_equal(pos_info)
    text = @fetcher.fetch
    type = :assign
    
    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :equal
    elsif @fetcher.current == ">"
      text << @fetcher.fetch
      type = :to
    end
    
    Token.new(pos_info, type, text)
  end
  def fetch_less_than(pos_info)
    text = @fetcher.fetch
    type = :lt
    
    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :le
    elsif @fetcher.current == "<"
      text << @fetcher.fetch
      type = :lt2
    end
    
    Token.new(pos_info, type, text)
  end
  def fetch_greater_than(pos_info)
    text = @fetcher.fetch
    type = :gt
    
    if @fetcher.current == "="
      text << @fetcher.fetch
      type = :ge
    elsif @fetcher.current == ">"
      text << @fetcher.fetch
      type = :gt2
    end
    
    Token.new(pos_info, type, text)
  end
  def fetch_dot(pos_info)
    text = @fetcher.fetch
    type = :dot
    
    if @fetcher.current == "."
      text << @fetcher.fetch
      type = :dot2
      
      if @fetcher.current == "."
        text << @fetcher.fetch
        type = :dot3
      end
    end
    
    Token.new(pos_info, type, text)
  end
  def fetch_punctuation(pos_info)
    char = @fetcher.current

    if !PUNCTUATION_TYPES.key?(char)
      unexpected_text @fetcher.pos, char
    else
      char = @fetcher.fetch
      Token.new(pos_info, PUNCTUATION_TYPES[char], char)
    end
  end

  public
  def tokenize
    tokens = []

    while @fetcher.has_next?
      pos_info = position_info(@fetcher.pos)
      char = @fetcher.current

      if ParsingConst::WHITESPACES.index(char)
        token = fetch_whitespace(pos_info)
      elsif ParsingConst::LINEFEED.index(char)
        token = fetch_linefeed(pos_info)
      elsif char == "#"
        token = fetch_comment(pos_info)
      elsif ParsingConst::LETTERS_EXT.index(char)
        token = fetch_identifier(pos_info)
      elsif ParsingConst::QUOTES.index(char)
        token = fetch_string(pos_info)
      elsif ParsingConst::NUMBERS.index(char)
        token = fetch_number(pos_info)
      elsif char == "+"
        token = fetch_plus(pos_info)
      elsif char == "-"
        token = fetch_minus(pos_info)
      elsif char == "*"
        token = fetch_star(pos_info)
      elsif char == "/"
        token = fetch_slash(pos_info)
      elsif char == "&"
        token = fetch_and(pos_info)
      elsif char == "|"
        token = fetch_or(pos_info)
      elsif char == "!"
        token = fetch_not(pos_info)
      elsif char == "="
        token = fetch_equal(pos_info)
      elsif char == "<"
        token = fetch_less_than(pos_info)
      elsif char == ">"
        token = fetch_greater_than(pos_info)
      elsif char == "."
        token = fetch_dot(pos_info)
      else
        token = fetch_punctuation(pos_info)
      end

      tokens << token if token
    end

    tokens
  end
end
