class FlotRenderer < BaseRenderer
  def to_html
    data = []
    graph_type = ''
    if series[0].type.to_sym == :bar
      graph_type = "bars"
      series.each_with_index do |s, i|
        data << "[#{i}, #{s.y_values[0]}]"
      end
    else
      graph_type = "lines"
      1.upto(series[0].x_values.size.to_i - 1) do |index|
        data << "[#{series[0].x_values[index]}, #{series[0].y_values[index]}]"
      end
    end

    html = <<GRAPH_HTML
    <div style="with:600px;height:350px;" id="#{graph_name}"></div>
    <script language="javascript" type="text/javascript">
    //#{series.inspect}
        $('.report').show();
        $.plot($("##{graph_name}"), [
            {
                data: [#{data.join(",")}],
                #{graph_type}: { show: true, fill: true }
            }
        ]);
        $('.report').hide();
        show_report('overview');
    </script>
GRAPH_HTML
    html
  end

  def self.header_html
    html = <<HEADER_HTML
    <script type="text/javascript" src="http://127.0.0.1:1234/jquery.js"></script>
    <script type="text/javascript" src="http://127.0.0.1:1234/jquery.flot.js"></script>
HEADER_HTML
  end

private
  def format_file_name(desired_name)
    desired_name.to_s.gsub("/","_").gsub("=","_").gsub("?","_")
  end

  def graph_name
    @graph_name ||= "graph_#{format_file_name(path || 'overview')}_#{(rand * 100).to_i}"
  end
end