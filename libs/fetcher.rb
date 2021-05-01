class Fetcher
  attr_reader :pos

  private
  def initialize(data)
    @data = data
    @length = data.length
    @max = @length - 1
    @pos = 0
  end

  public
  def pos=(value)
    if (value >= 0) && (value <= @max)
      @pos = value
    else
      raise "Invalid pos value: #{value}."
    end
  end
  def has_next?
    (@length > 0) && (@pos <= @max)
  end
  def prev
    @pos > 0 ? @data[@pos - 1] : nil
  end
  def next
    @pos < @max ? @data[@pos + 1] : nil
  end
  def current
    @data[@pos]
  end
  def [](index)
    (index >= 0) && (index <= @max) ? @data[index] : nil
  end
  def fetch
    if has_next?
      result = @data[@pos]
      @pos += 1
      result
    else
      nil
    end
  end
end
