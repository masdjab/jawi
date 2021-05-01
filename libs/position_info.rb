class PositionInfo
  attr_accessor :pos, :row, :col
  def initialize(pos, row, col)
    @pos = pos
    @row = row
    @col = col
  end
  def ==(rc)
    (rc.row == @row) && (rc.col = @col)
  end
  def to_s
    "#{@row}:#{@col}"
  end
end
