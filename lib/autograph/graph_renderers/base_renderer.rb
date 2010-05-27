class BaseRenderer
  attr :title, true
  attr :width, true
  attr :height, true
  attr :path, true
  attr :series

  AVAILABLE_GRAPH_RENDERERS = %W(FlotRenderer)

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

  def self.header_html
  end

  def self.footer_html
  end

  def self.generate_graphs(reports, configuration)
    graphs = {}
    reports.each do |uri, report|
      graphs[uri] = []

      puts "For '#{uri}' the values are #{report.column('reply time').join(', ')}" if configuration['verbose']
      request_rate_graph = configuration.graph_renderer_class.new
      request_rate_graph.title = "Demanded vs. Achieved Request Rate (r/s)"
      request_rate_graph.path = uri

      request_rate = GraphSeries.new(:line, report.column('rate'), report.column('conn/s').map{|x| x.to_f}, "Request rate for '#{uri}'")
      request_rate_graph.add_series(request_rate)

      graphs[uri] << request_rate_graph

      response_time_graph = configuration.graph_renderer_class.new
      response_time_graph.path = uri
      response_time_graph.title = "Demanded Request Rate (r/s) vs. Response Time"

      response_time = GraphSeries.new(:line, report.column('rate'), report.column('reply time'), "Response time for '#{uri}'")
      response_time_graph.add_series(response_time)

      graphs[uri] << response_time_graph
    end

    max_rate_graph = configuration.graph_renderer_class.new
    max_rate_graph.title = "Max Achieved Connection Rate"
    max_rate_graph.width  = 600
    max_rate_graph.height = 300

    reports.keys.each do |key|
      max = reports[key].column('conn/s').map{|x| x.to_i}.max.to_i
      max_request_rate = GraphSeries.new(:bar, [key], [max], "Max Request Rate for '#{key}'")
      max_request_rate.path = key
      max_rate_graph.add_series(max_request_rate)
    end

    graphs['summary_graph'] = max_rate_graph
    graphs
  end
end