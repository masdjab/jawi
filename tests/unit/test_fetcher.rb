require 'test-unit'
require_relative '../../libs/fetcher'


class TestParser < Test::Unit::TestCase
  def test_using_string
    data = "12345"
    fetcher = Fetcher.new(data)
    assert_true fetcher.has_next?
    assert_equal 0, fetcher.pos
    assert_equal nil, fetcher.prev
    assert_equal "1", fetcher.current
    assert_equal "2", fetcher.next
    assert_equal "1", fetcher.fetch
    assert_equal "1", fetcher.prev
    assert_equal "2", fetcher.fetch
    assert_equal "3", fetcher.fetch
    assert_equal "4", fetcher.fetch
    assert_equal "5", fetcher.fetch
    assert_equal nil, fetcher.next
    assert_equal nil, fetcher.fetch
    assert_equal 5, fetcher.pos
  end
  def test_using_array
    data = ["1", "2", "3", "4", "5"]
    fetcher = Fetcher.new(data)
    assert_true fetcher.has_next?
    assert_equal 0, fetcher.pos
    assert_equal nil, fetcher.prev
    assert_equal "1", fetcher.current
    assert_equal "2", fetcher.next
    assert_equal "1", fetcher.fetch
    assert_equal "1", fetcher.prev
    assert_equal "2", fetcher.fetch
    assert_equal "3", fetcher.fetch
    assert_equal "4", fetcher.fetch
    assert_equal "5", fetcher.fetch
    assert_equal nil, fetcher.next
    assert_equal nil, fetcher.fetch
    assert_equal 5, fetcher.pos
  end
end
