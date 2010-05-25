require 'gchart'

class GChartRenderer < BaseRenderer

  def to_html
    render_graph
    "<img src='#{render_graph.to_url}'/>"
  end

private
  def available_colors
    [:red, :yellow, :green, :blue, :black]
  end

  def render_graph
    chart_type = series[0].type.to_s
    chart_type = 'line' if chart_type == 'area'

    chart = GChart.send(chart_type) do |g|

      x_values = series[0].x_values
      y_values = series[0].y_values

      x_values = series.map{|s| s.x_values} if chart_type.to_sym == :bar

      series_data = series.map{|s| s.y_values}

      g.data   = series_data

      # chg, grid lines
      # chm data point makers
      # chma, margins
      # chm, flags  :chm => "fMax,FF0000,0,#{y_values.index(y_values.max)},15"
      # cht, bvg (bar vertical grouped)
      # chbh, bar spacing
      # chdlp, legend on bottom, vertical

      # TODO: Should case off of chart types

      extras = {:chg => "#{100/(y_values.size)},20,1,5",
                :chm => "o,0066FF,0,-1.0,6",
                :chma => "20,20,20,30|80,20",
                :chdlp => "bv"}

      if chart_type.to_sym == :bar
        extras = extras.merge({:chm => '', :chbh => 'a,20,20'})
        # chm=N*f0*,000000,1,-1,11|N*f0*,000000,2,-1,11|N*f1*,000000,3,-1,11|N*f2*,FF0000,0,0,18
        g.grouped = true
      end

      g.extras = extras

      g.axis(:bottom) do |a|
        a.labels          = [0] << x_values
        a.text_color = :black
      end

      g.axis(:left) do |a|
        interval = (y_values.max/10).to_i
        interval = 1 if interval == 0
        a.labels = (0..(y_values.max.to_i)).to_a.select{|y| y % interval == 0}
        a.text_color = :black
      end

      if chart_type.to_sym == :bar
        g.orientation = :vertical
      end

      colors = available_colors
      g.colors = series.map{|s| colors.pop}

      g.legend = series.map{|s| s.label.gsub("'", "")}

      g.title = title

      g.width  = width
      g.height = height

      g.entire_background = "f4f4f4"
    end
  end
end