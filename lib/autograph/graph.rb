class Graph
  attr :title, true
  attr :series

  def initialize(options={})
    @title = options[:title]
    @series = []
  end

  # def find_max_y_value
  #   series.map{|s| s.y_values.max}.max
  # end
end