require 'test-unit'
require_relative '../../libs/fetcher'
require_relative '../../compiler/parser/parser'


class TestParser < Test::Unit::TestCase
  def test_standard_parsing
    fetcher = Fetcher.new("123.45 0x20\r\n\r\r\n\n")
    parser = Parser.new(fetcher)
    assert_equal "123", parser.parse.text
    assert_equal ".", parser.parse.text
    assert_equal "45", parser.parse.text
    assert_equal " ", parser.parse.text
    assert_equal "0", parser.parse.text
    assert_equal "x", parser.parse.text
    assert_equal "20", parser.parse.text
    assert_equal "\r", parser.parse.text
    assert_equal "\n", parser.parse.text
    assert_equal "\r", parser.parse.text
    assert_equal "\r", parser.parse.text
    assert_equal "\n", parser.parse.text
    assert_equal "\n", parser.parse.text

    fetcher = Fetcher.new("puts _message.text\r\n")
    parser = Parser.new(fetcher)
    assert_equal "puts", parser.parse.text
    assert_equal " ", parser.parse.text
    assert_equal "_message", parser.parse.text
    assert_equal ".", parser.parse.text
    assert_equal "text", parser.parse.text

    fetcher = Fetcher.new("'' \"\" 'Hel\\tlo\"'")
    parser = Parser.new(fetcher)
    assert_equal "'", parser.parse.text
    assert_equal "'", parser.parse.text
    assert_equal " ", parser.parse.text
    assert_equal '"', parser.parse.text
    assert_equal '"', parser.parse.text
    assert_equal " ", parser.parse.text
    assert_equal "'", parser.parse.text
    assert_equal "Hel", parser.parse.text
    assert_equal "\\", parser.parse.text
    assert_equal "tlo", parser.parse.text
    assert_equal '"', parser.parse.text
    assert_equal "'", parser.parse.text
  end
  def test_parse_symbols
    text = "~`!@#$%^&*()-+[]{}|;:,<>/?."
    parser = Parser.new(Fetcher.new(text))
    (0...text.length).each do |i|
      assert_equal text[i], parser.parse.text
    end
  end
end
