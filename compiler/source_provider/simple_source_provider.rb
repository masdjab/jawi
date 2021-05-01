class SimpleSourceProvider
  private
  def initialize(source_dict)
    @source_dict = source_dict
  end

  public
  def get_source(name)
    @source_dict[name]
  end
end
