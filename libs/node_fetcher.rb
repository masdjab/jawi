require_relative 'fetcher'


class NodeFetcher < Fetcher
  private
  def initialize(data, whitespaces)
    super(data)
    @whitespaces = whitespaces
  end

  public
  def fetch
    node = super
    while current
      if @whitespaces.include?(current.type)
        super
      else
        break
      end
    end
    node
  end
end
