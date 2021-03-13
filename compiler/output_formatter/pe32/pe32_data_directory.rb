require_relative '../../../libs/binary_converter'
require_relative 'pe32_rva'


class Pe32DataDirectory
  ENTRIES_COUNT = 16

  attr_accessor \
    :export, :import, :resource, :exception, :certificate,
    :relocation, :debug, :architecture, :global_pointer,
    :tls, :load_config, :bound_import, :iat,
    :delay_import_descriptor, :clr_runtime_header,
    :reserved

  private
  def initialize
    @export = Pe32Rva.new(0, 0)
    @import = Pe32Rva.new(0, 0)
    @resource = Pe32Rva.new(0, 0)
    @exception = Pe32Rva.new(0, 0)
    @certificate = Pe32Rva.new(0, 0)
    @relocation = Pe32Rva.new(0, 0)
    @debug = Pe32Rva.new(0, 0)
    @architecture = Pe32Rva.new(0, 0)
    @global_pointer = Pe32Rva.new(0, 0)
    @tls = Pe32Rva.new(0, 0)
    @load_config = Pe32Rva.new(0, 0)
    @bound_import = Pe32Rva.new(0, 0)
    @iat = Pe32Rva.new(0, 0)
    @delay_import_descriptor = Pe32Rva.new(0, 0)
    @clr_runtime_header = Pe32Rva.new(0, 0)
    @reserved = Pe32Rva.new(0, 0)
  end
  def int2bin(data, size)
    BinaryConverter.int2bin(data, size)
  end

  public
  def count
    ENTRIES_COUNT
  end
  def to_bin
    rvas = [
        @export,
        @import,
        @resource,
        @exception,
        @certificate,
        @relocation,
        @debug,
        @architecture,
        @global_pointer,
        @tls,
        @load_config,
        @bound_import,
        @iat,
        @delay_import_descriptor,
        @clr_runtime_header,
        @reserved,
    ]

    rvas.map{|x|x.to_bin}.join
  end
end
