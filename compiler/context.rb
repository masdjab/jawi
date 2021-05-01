class Context
  attr_reader :name, :type, :parent
  def initialize(name, type, parent)
    @name = name
    @type = type
    @parent = parent
  end
  def to_s
    "#{@parent ? "#{@parent}." : ""}#{@name}"
  end
end
