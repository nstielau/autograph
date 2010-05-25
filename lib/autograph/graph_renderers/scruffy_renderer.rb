require 'scruffy'

class ScruffyRenderer < BaseRenderer
  SCRUFFY_HEIGHT=360
  SCRUFFY_WIDTH=600

  def to_html
    render_graph
    "<iframe width=\"#{SCRUFFY_WIDTH}\" height=\"#{SCRUFFY_HEIGHT}\" src=\"./#{graph_file_name}\"></iframe>"
  end

private
  def format_file_name(desired_name)
    desired_name.to_s.gsub("/","_").gsub("=","_").gsub("?","_")
  end

  def graph_file_name
    @graph_name ||= "graph_#{format_file_name(path || 'overview')}_#{(rand * 100).to_i}.svg"
  end

  def render_graph
    graph = Scruffy::Graph.new
    graph.title = title
    graph.renderer = Scruffy::Renderers::Standard.new(:values => series[0].x_values.size + 1)
    graph.point_markers = series[0].x_values

    series.each do |s|
      graph.add s.type.to_sym, s.label, s.y_values
    end

    graph.render :to => graph_file_name, :min_value => 0, :max_value => find_max_y_value, :width => SCRUFFY_WIDTH, :height => SCRUFFY_HEIGHT

    graph
  end
end