require 'test-unit'
require_relative '../../compiler/parser/token'
require_relative '../../libs/node_fetcher'


class TestParser < Test::Unit::TestCase
  def test_fetch
    tokens = [
        {'type' => :whitespace, 'text' => ' \t '},
        {'type' => :identifier, 'text' => 'x'},
        {'type' => :whitespace, 'text' => ' '},
        {'type' => :assignment, 'text' => '='},
        {'type' => :whitespace, 'text' => ' '},
        {'type' => :assignment, 'text' => '2'},
    ]

    tokens = tokens.map{|t|Token.new(0, t['type'], t['text'])}
    fetcher = NodeFetcher.new(tokens, [:whitespace])
    assert_equal ' \t ', fetcher.fetch.text
    assert_equal 'x', fetcher.fetch.text
    assert_equal '=', fetcher.fetch.text
    assert_equal '2', fetcher.fetch.text
    assert_true fetcher.current.nil?
  end
end
