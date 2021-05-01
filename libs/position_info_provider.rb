require_relative 'position_info'


class PositionInfoProvider
  private
  def initialize(source, line_separator = nil)
    @source = source
    @line_separator = line_separator ? line_separator : $/
    @line_numbers = nil
  end
  def line_numbers
    if @line_numbers.nil?
      line_nums = []
      line_no = 1
      char_pos = 0

      @source.lines(@line_separator).each do |line|
        line_nums << {'line_no' => line_no, 'min' => char_pos, 'max' => char_pos + line.length - 1}
        char_pos = char_pos + line.length
        line_no += 1
      end

      @line_numbers = line_nums
    end

    @line_numbers
  end
  
  public
  def get_position_info(pos)
    result = nil
    line_nums = line_numbers
    
    if pos < 0
      result = PositionInfo.new(pos, 1, 1)
    elsif pos > (item = line_nums.last)['max']
      result = PositionInfo.new(pos, item['line_no'], @source.length - item['min'] + 1)
    elsif item = line_nums.find{|x|(x['min'] <= pos) && (pos <= x['max'])}
      result = PositionInfo.new(pos, item['line_no'], pos - item['min'] + 1)
    end
    
    result
  end
end
