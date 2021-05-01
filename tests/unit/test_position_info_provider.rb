require 'test-unit'
require_relative '../../libs/position_info'
require_relative '../../libs/position_info_provider'


class TestPositionInfoProvider < Test::Unit::TestCase
  def test_calc_row_col
    source = <<EOS
12345
12345
12345
EOS

    provider = PositionInfoProvider.new(source)
    assert_equal PositionInfo.new(0, 1, 1), provider.get_position_info(0)
    assert_equal PositionInfo.new(4, 1, 5), provider.get_position_info(4)
    assert_equal PositionInfo.new(6, 2, 1), provider.get_position_info(7)
  end
end
