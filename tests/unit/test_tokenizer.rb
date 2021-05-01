require 'test-unit'
# require 'mocha/test_unit'
require_relative '../../libs/position_info_provider'
require_relative '../../libs/fetcher'
require_relative '../../compiler/parser/parsing_exceptions'
require_relative '../../compiler/parser/token'
require_relative '../../compiler/parser/tokenizer'


class TestTokenizer < Test::Unit::TestCase
  def tokenize(source_code)
    fetcher = Fetcher.new(source_code)
    position_info_provider = PositionInfoProvider.new(source_code)
    tokenizer = Tokenizer.new(fetcher, position_info_provider)
    tokenizer.tokenize
  end
  def assert_single_number(source_code)
    tokens = tokenize(source_code)
    assert_equal 1, tokens.count
    assert_equal 1, tokens[0].pos.col
    assert_equal :number, tokens[0].type
  end
  def test_parse_return_type
    tokens = tokenize("x = 2")
    assert_equal true, tokens.is_a?(Array)
    assert_equal true, tokens[0].is_a?(Token)
    assert_equal 5, tokens.count
    assert_equal [1, 2, 3, 4, 5], tokens.map{|x|x.pos.col}
  end
  def test_parse_whitespace
    tokens = tokenize("  \t  \t  ")
    assert_equal 1, tokens.count
    assert_equal :whitespace, tokens.first.type
  end
  def test_parse_linefeed
    tokens = tokenize("x\r")
    assert_equal 2, tokens.count
    assert_equal :cr, tokens[1].type

    tokens = tokenize("x\n")
    assert_equal 2, tokens.count
    assert_equal :lf, tokens[1].type

    tokens = tokenize("x\r\n")
    assert_equal 2, tokens.count
    assert_equal :crlf, tokens[1].type

    tokens = tokenize("x\r\r\n")
    assert_equal 3, tokens.count
    assert_equal :cr, tokens[1].type
    assert_equal :crlf, tokens[2].type

    tokens = tokenize("\r\n\r\n")
    assert_equal 2, tokens.count
    assert_equal :crlf, tokens[0].type
    assert_equal :crlf, tokens[1].type

    tokens = tokenize("\r\n\n")
    assert_equal 2, tokens.count
    assert_equal :crlf, tokens[0].type
    assert_equal :lf, tokens[1].type
  end
  def test_parse_comment
    tokens = tokenize("aku#sudah tahu")
    assert_equal 2, tokens.count
    assert_equal :comment, tokens[1].type

    tokens = tokenize("   \t   #  sudah lah # # #")
    assert_equal 2, tokens.count
    assert_equal :comment, tokens[1].type
  end
  def test_parse_number
    assert_single_number "000"
    assert_single_number "001"
    assert_single_number "1234567890"
    assert_single_number "0.215"
    assert_single_number "000.0"
    assert_single_number "000.000"
    assert_single_number "000.128"
    assert_single_number "000.123456789"
    assert_single_number "0.123456789"
    assert_single_number "22.123456789"
    assert_single_number "123456789.456"
    assert_single_number "0x213254"
    assert_single_number "0xabcdef"
    assert_single_number "0x12ac"

    tokens = tokenize("12345.to_s")
    assert_equal 3, tokens.count
    assert_equal [:number, :dot1, :identifier], tokens.map{|x|x.type}
    assert_equal [1, 6, 7], tokens.map{|x|x.pos.col}
    assert_equal ["12345", ".", "to_s"], tokens.map{|x|x.text}

    assert_raise(UnexpectedTextException){tokenize("0x2e.4")}
    assert_raise(ExpectedTextException){tokenize("0.")}
    assert_raise(ExpectedTextException){tokenize("123.")}
    assert_raise(UnexpectedTextException){tokenize("00x33")}
    assert_raise(UnexpectedTextException){tokenize("1x22")}
    assert_raise(UnexpectedTextException){tokenize("12345x22")}
    assert_raise(UnexpectedTextException){tokenize("0a")}
    assert_raise(UnexpectedTextException){tokenize("0_")}
    assert_raise(ExpectedTextException){tokenize("0x")}
    assert_raise(ExpectedTextException){tokenize("0xm")}
    assert_raise(ExpectedTextException){tokenize("0x_")}
    assert_raise(ExpectedTextException){tokenize("0x.")}
    assert_raise(ExpectedTextException){tokenize("0x(")}
    assert_raise(UnexpectedTextException){tokenize("0x1.2")}
    assert_raise(UnexpectedTextException){tokenize("0.0.0")}
  end
  def test_parse_string
    tokens = tokenize("x='I said \"hello...\", right?'")
    assert_equal 3, tokens.count
    assert_equal [:identifier, :assign, :string], tokens.map{|x|x.type}
    assert_equal "'I said \"hello...\", right?'", tokens[2].text

    tokens = tokenize("'Hello \"programming\" world...'")
    assert_equal "'Hello \"programming\" world...'", tokens[0].text

    tokens = tokenize("\"Hello 'programming' world...\r\n\t\"")
    assert_equal "\"Hello 'programming' world...\r\n\t\"", tokens[0].text
  end
  def test_parse_identifier
    tokens = tokenize("_=2")
    assert_equal 3, tokens.count
    assert_equal [:identifier, :assign, :number], tokens.map{|x|x.type}

    tokens = tokenize("person_2115  \t  = \t xxx")
    assert_equal 5, tokens.count
    assert_equal [:identifier, :whitespace, :assign, :whitespace, :identifier], tokens.map{|x|x.type}
  end
  def test_assign_equal
    tokens = tokenize("a=b")
    assert_equal 3, tokens.count
    assert_equal "=", tokens[1].text

    tokens = tokenize("a==b")
    assert_equal 3, tokens.count
    assert_equal "==", tokens[1].text

    tokens = tokenize("a===b")
    assert_equal 4, tokens.count
    assert_equal "==", tokens[1].text
    assert_equal "=", tokens[2].text
  end
  def test_less_than
    tokens = tokenize("a<2")
    assert_equal 3, tokens.count
    assert_equal :lt1, tokens[1].type

    tokens = tokenize("a<=2")
    assert_equal 3, tokens.count
    assert_equal :le, tokens[1].type
    assert_equal "<=", tokens[1].text

    tokens = tokenize("a<====2")
    assert_equal 5, tokens.count
    assert_equal [:identifier, :le, :equal, :assign, :number], tokens.map{|x|x.type}
    assert_equal ["a", "<=", "==", "=", "2"], tokens.map{|x|x.text}
  end
  def test_greater_than
    tokens = tokenize("a>2")
    assert_equal 3, tokens.count
    assert_equal :gt1, tokens[1].type

    tokens = tokenize("a>=2")
    assert_equal 3, tokens.count
    assert_equal :ge, tokens[1].type
    assert_equal ">=", tokens[1].text

    tokens = tokenize("a>====2")
    assert_equal 5, tokens.count
    assert_equal [:identifier, :ge, :equal, :assign, :number], tokens.map{|x|x.type}
    assert_equal ["a", ">=", "==", "=", "2"], tokens.map{|x|x.text}
  end
  def test_and_or
    tokens = tokenize("a&b")
    assert_equal 3, tokens.count
    assert_equal "&", tokens[1].text

    tokens = tokenize("a&&b")
    assert_equal 3, tokens.count
    assert_equal "&&", tokens[1].text

    tokens = tokenize("a&&&b")
    assert_equal 4, tokens.count
    assert_equal "&&", tokens[1].text
    assert_equal "&", tokens[2].text

    tokens = tokenize("a|b")
    assert_equal 3, tokens.count
    assert_equal "|", tokens[1].text

    tokens = tokenize("a||b")
    assert_equal 3, tokens.count
    assert_equal "||", tokens[1].text

    tokens = tokenize("a|||b")
    assert_equal 4, tokens.count
    assert_equal "||", tokens[1].text
    assert_equal "|", tokens[2].text
  end
  def test_punctuations
    tests =
        [
            [".,:;()",    [:dot1, :comma, :colon, :semicolon, :lbrk, :rbrk]],
            ["[]{}+-*",   [:lsbrk, :rsbrk, :lcbrk, :rcbrk, :plus, :minus, :star]],
            ["/\\?!@~`",  [:slash, :bslash, :question, :exclamation, :at, :tilde, :bquote]],
            ["$%^|||&&&", [:dollar, :percent, :xor, :or2, :or1, :and2, :and1]]
        ]

    tests.each{|t|assert_equal t[1], tokenize(t[0]).map{|x|x.type}}
  end
end
