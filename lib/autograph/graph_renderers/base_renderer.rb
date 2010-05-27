class BaseRenderer


  def to_html
    js_series = []
    graph_type = ''
    if series[0].type.to_sym == :bar
      graph_type = "bars"
      series.each_with_index do |s, i|
        js_series << "{data: [[#{i}, #{s.y_values[0]}]], label: \"#{s.label}\", bars: { show: true, fill: true }}"
      end
    else
      graph_type = "lines"
      data = []
      1.upto(series[0].x_values.size.to_i - 1) do |index|
        data << "[#{series[0].x_values[index]}, #{series[0].y_values[index]}]"
      end
      js_series << "{data: [#{data.join(", ")}], label: \"#{series[0].label}\", lines: { show: true, fill: true }}"
    end
    #    var data = [{ data: [[1,1]], label: "Pressure", color: "#333" }, { data: [[2,3]], label: "Temperature", color: "#FF0000" }];
    html = <<GRAPH_HTML
    <h2>#{title}</h2>
    <div class="flot-graph" style="with:600px;height:350px;" id="#{graph_name}"></div>
GRAPH_HTML

    js = <<GRAPH_JS
    <script language="javascript" type="text/javascript">
    //#{series.inspect}
        $('.report').show();
        $.plot($("##{graph_name}"), [
          #{js_series.join(", ")}
        ], default_graph_options);
        $('.report').hide();
        show_report('overview');
    </script>
GRAPH_JS
    @@footer_html ||= ""
    @@footer_html = @@footer_html.to_s + js
    html
  end

  def self.header_html
    html = <<HEADER_HTML
    <script type="text/javascript" src="http://nstielau.github.com/autograph/js/jquery.js"></script>
    <script type="text/javascript" src="http://nstielau.github.com/autograph/js/jquery.flot.js"></script>
HEADER_HTML
  end

  def self.footer_html
    @@footer_html ||= ""
    footer_html = <<FOOTER_HTML
  <script language="javascript" type="text/javascript">
    var acolor;
    var default_graph_options = {
      series: {
        lines: { show: true, lineWidth: 3 },
        points: { show: true, radius: 4 }
      },
      legend: {
        show: true,
        backgroundColor: '#FFF',
        backgroundOpacity: 0.9
      },
      series: {
        lines: { show: true, lineWidth: 3 },
        points: { show: true, fill: false },
        shadowSize: 0,
      },
      xaxis: {
      },
      yaxis: {
        show: true,
      },
      grid: {
        show: true,
        backgroundColor: null,
        borderWidth: 0,
        hoverable: true,
        tickColor: "#E1E8F0",
      },
      colors: ["#5bba47","#d86b6d","#3d8aea","#333333"]
    };

    // Callback function to show the tooltip
    function showTooltip(item) {
      var contents = "(" + item.datapoint[1] + "," + item.datapoint[0] + ")";
      var x = item.pageX;
      var y = item.pageY - 10;

      var obj = $('<div id="flot-tooltip">' + contents + '</div>').css( {
        padding: '5px',
        position: 'absolute',
        minWidth: '5em',
        display: 'block',
        top:  y+5,
        left: x+5,
        zIndex: 9999
      });

      obj.appendTo('body').fadeIn('200');
    }

    // Var to hold our previous point
    var previousPoint = null;

    // Bind to the plothover so we can show a tooltip
    $(".flot-graph").bind("plothover", function (event, pos, item) {
      if (item) {
        if (previousPoint != item.datapoint) {
          previousPoint = item.datapoint;
          $("#flot-tooltip").remove();
          showTooltip(item);
        }
      } else {
        $('#flot-tooltip').remove().fadeOut('200');
        previousPoint = null;
      }
    });
</script>
FOOTER_HTML
  footer_html + @@footer_html
  end

  def self.generate_graphs(reports, configuration)
    graphs = {}
    graphs[:request_rate]  = Graph.new(:title => "Demanded vs. Achieved Request Rate (r/s)")
    graphs[:response_time] = Graph.new(:title => "Demanded Request Rate (r/s) vs. Response Time")
    graphs[:max_request_rate] = Graph.new(:title => "Maximum Achieved Request Rate")
    reports.each do |uri, report|
      graphs[:request_rate].series << GraphSeries.new(:line, report.column('rate'), report.column('conn/s').map{|x| x.to_f}, "Request rate for '#{uri}'")
      graphs[:response_time].series << GraphSeries.new(:line, report.column('rate'), report.column('reply time'), "Response time for '#{uri}'")
    end

    reports.keys.each_with_index do |key, index|
      max = reports[key].column('conn/s').map{|x| x.to_i}.max.to_i
      max_request_rate = GraphSeries.new(:bar, [index], [max], "Max Request Rate for '#{key}'")
      graphs[:max_request_rate].add_series(max_request_rate)
    end

    graphs
  end

private
  def format_file_name(desired_name)
    desired_name.to_s.gsub("/","_").gsub("=","_").gsub("?","_")
  end

  def graph_name
    @graph_name ||= "graph_#{format_file_name(path || 'overview')}_#{(rand * 100).to_i}"
  end
end