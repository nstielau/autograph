require 'scruffy'

class ScruffyRenderer < BaseRenderer
  
  def to_html
    render_graph
    "<img src='#{@file_name}'/>"
  end
  
private
  def format_file_name(desired_name)
    desired_name.gsub("/","_").gsub("=","_").gsub("?","_")
  end

  def render_graph
    graph = Scruffy::Graph.new
    graph.title = title
    graph.renderer = Scruffy::Renderers::Standard.new(:values => series[0].x_values.size + 1)
    graph.point_markers = series[0].x_values
    
    series.each do |s|
      graph.add s.type.to_sym, s.label, s.y_values
    end
    
    @file_name = format_file_name("request_graph_#{path}.svg")
    
    graph.render :to => @file_name, :min_value => 0, :max_value => find_max_y_value
    
    graph
  end
end