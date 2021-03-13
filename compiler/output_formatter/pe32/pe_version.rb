require_relative '../../../libs/binary_converter'


class PeVersion
  attr_accessor :major, :minor
  def initialize(major = nil, minor = nil)
    @major = major
    @minor = minor
  end
  def to_bin(format = :word)
    [@major, @minor].map{|x|Converter.int2bin(x ? x : 0, format)}.join
  end
end
