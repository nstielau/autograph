class BaseRenderer
  attr :title, true
  attr :width, true
  attr :height, true
  attr :path, true
  attr :series
  
  def initialize
    @series = []
  end
  
  def add_series(new_series)
    series.push(new_series)
  end
  
  def to_html
    return "DATA"
  end
  
  def find_max_y_value
    series.map{|s| s.y_values.max}.max
  end
end