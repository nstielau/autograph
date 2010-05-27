class Graph
  attr :title, true
  attr :series

  def initialize(options={})
    @title = options[:title]
    @series = []
  end
end