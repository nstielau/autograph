class GraphSeries
  attr :x_values, true
  attr :y_values, true
  attr :label, true
  attr :type, true
  attr :path, true

  def initialize(t, xs, ys, l, p=nil)
    @type = t
    @x_values = xs.map{|x| x.to_f}
    @y_values = ys.map{|x| x.to_f}
    @label = l
    @path = p
  end

end