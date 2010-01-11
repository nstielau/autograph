class AutoPerf
  
  def initialize(opts = {})
    @reports = {}
    @graphs = {}
    @conf = {'httperf_timeout' => 20, 
             'httperf_num-call'  => 1, 
             'httperf_num-conns' => 100, 
             'httperf_rate' => 5, 
             'port' => 80, 
             'uri' => '/',
             'low_conns'  => 50,
             'high_conns' => 550,
             'conns_step' => 100,
             'low_rate'  => 5,
             'high_rate' => 250,
             'rate_step' => 20,
             'uris' => ['/'],
             'use_test_data' => false,
             'batik-rasterizer-jar' => '/opt/batik/batik-rasterizer.jar',
             'graph_renderer' => 'GChartRenderer',
             'average' => false,
             'output_dir' => './'
             }.merge(opts)
    
    # This is a little too much 'magic'
    if @conf['httperf_wsesslog']
      puts "Using httperf_wsesslog"
      @conf.delete("httperf_num-call")
      @conf.delete("httperf_num-conns")
      @conf["httperf_add-header"] = "'Content-Type: application/x-www-form-urlencoded\\n'"
      # TODO: Add AcceptEncoding: gzip,deflate option
    end

    if opts['verbose']
      puts
      puts "Use these parameters:"
      @conf.sort.each{ |k, v| puts "  #{k}=#{v}"}
      puts
    end

    run()
  end
  
  
  def run
    if @conf['use_test_data']
      load_test_data()
    else
      run_tests()
    end
    
    generate_graphs()
    generate_html_report()
  end
  

  def benchmark(conf)
    httperf_opt = conf.keys.grep(/httperf/).collect {|k| "--#{k.gsub(/httperf_/, '')} #{conf[k]}"}.join(" ")
    httperf_cmd = "httperf --hog --server #{conf['host']} --port #{conf['port']} #{httperf_opt}"

    res = Hash.new("")
    IO.popen("#{httperf_cmd} 2>&1") do |pipe|
      puts "\n#{httperf_cmd}"

      while((line = pipe.gets))
        res['output'] += line

        case line
        when /^Total: .*replies (\d+)/ then res['replies'] = $1
        when /^Connection rate: (\d+\.\d)/ then res['conn/s'] = $1
        when /^Request rate: (\d+\.\d)/ then res['req/s'] = $1
        when /^Reply time .* response (\d+\.\d)/ then res['reply time'] = $1
        when /^Net I\/O: (\d+\.\d)/ then res['net io (KB/s)'] = $1
        when /^Errors: total (\d+)/ then res['errors'] = $1
        when /^Reply rate .*min (\d+\.\d) avg (\d+\.\d) max (\d+\.\d) stddev (\d+\.\d)/ then
          res['replies/s min'] = $1
          res['replies/s avg'] = $2
          res['replies/s max'] = $3
          res['replies/s stddev'] = $4
        end
      end
    end

    return res
  end

  def vary_rate(override_opts = {})
    puts "Overrides are #{override_opts.inspect}" if @conf['verbose']
    results = {}
    report = Table(:column_names => ['rate', 'conn/s', 'req/s', 'replies/s avg',
                                     'errors', 'net io (KB/s)', 'reply time'])

    (@conf['low_rate']..@conf['high_rate']).step(@conf['rate_step']) do |rate|
      results[rate] = benchmark(@conf.merge({'httperf_rate' => rate}.merge(override_opts)))
      report << results[rate].merge({'rate' => rate})

      puts report.to_s
      puts results[rate]['output'] if results[rate]['errors'].to_i > 0
    end
    
    report
  end
  
  def run_tests
    @conf['uris'].uniq.each do |uri|
      @reports[uri] = vary_rate('httperf_uri' => uri)
    end
    
    # TODO: Factor out to create_httperf_wlog
    if !@conf['httperf_wlog'] && @conf['uris'].length > 1 && @conf['average']
      replay_log = File.open('tmp_replay_log', 'w')
      path = replay_log.path
      puts "Tmp replay log is at #{path}" if @conf['verbose']
      index = 1
      @conf['uris'].each do |uri|
        replay_log.print uri
        replay_log.putc 0 if index < @conf['uris'].length # ASCII NUL Terminate join paths
        index = index + 1
      end
      replay_log.close
      puts "Replay log is at #{path}" if @conf['verbose']
      @reports["Avg"] = vary_rate('httperf_wlog' => "y,#{path}")
    end
  end
  
  def generate_graphs
    @reports.each do |uri, report| 
      @graphs[uri] = []
      
      puts "For '#{uri}' the values are #{report.column('reply time').join(', ')}" if @conf['verbose']      
      graph_1 = graph_renderer_class.new
      graph_1.title = "Demanded vs. Achieved Request Rate (r/s)"
      graph_1.path = uri
      graph_1.width  = 600
      graph_1.height = 300

      if @reports['Avg']
        avg_request_rate = GraphSeries.new(:area, report.column('rate'), @reports['Avg'].column('conn/s').map{|x| x.to_f}, "Avg")
        graph_1.add_series(avg_request_rate)
      end
      
      request_rate = GraphSeries.new(:line, report.column('rate'), report.column('conn/s').map{|x| x.to_f}, "Requests for '#{uri}'")
      graph_1.add_series(request_rate)
      
      @graphs[uri] << graph_1.to_html

      graph_2 = graph_renderer_class.new
      graph_2.path = uri
      graph_2.title = "Demanded Request Rate (r/s) vs. Response Time"
      graph_2.width  = 600
      graph_2.height = 300
      
      if @reports['Avg']
        avg_response_time = GraphSeries.new(:area, report.column('rate'), @reports['Avg'].column('reply time').map{|x| x.to_f}, "Avg")
        graph_2.add_series(avg_response_time)
      end
      
      response_time = GraphSeries.new(:line, report.column('rate'), report.column('reply time'), "Requests for '#{uri}'")
      graph_2.add_series(response_time)

      @graphs[uri] << graph_2.to_html
    end
    
    graph_3 = graph_renderer_class.new
    #graph_3.path = uri
    graph_3.title = "Max Achieved Connection Rate"
    graph_3.width  = 600
    graph_3.height = 300  
    
    @reports.keys.each do |key|
      max = @reports[key].column('conn/s').map{|x| x.to_i}.max.to_i
      max_request_rate = GraphSeries.new(:bar, [key], [max], "Max Request Rate for '#{key}'")
      graph_3.add_series(max_request_rate)
    end
    @summary_graph = graph_3
  end
  
  
#private

  def load_test_data
    defaults = {:column_names => ['rate', 'conn/s', 'req/s', 'replies/s avg', 'errors', 'net io (KB/s)', 'reply time']}
    @conf['uris'] = ['/', '/page1', '/page2']
    @conf['uris'].each do |uri|
      @reports[uri] = ::Ruport::Data::Table.new(defaults)
      times = [130.7, 132.7, 180.4, 438.3, 591.9, 686.9, 739.4, 661.3, 727.1, 546.5, 711.1, 893.7, 870.0]
      conns = [5.0, 21.5, 28.8, 30.6, 26.3, 24.7, 23.0, 25.8, 28.0, 27.4, 27.9, 22.2, 22.7]
      1.upto(10) do |i|
        @reports[uri] << {'rate' => i*10 - 10, 
                          'conn/s' => conns[rand(conns.length)], 
                          'reply time' => times[rand(conns.length)]}
      end
    end
  end


  def generate_html_report
    HtmlReport.new({
      'host' => @conf['host'],
      'title' => "Report for #{@conf['host']}",
      'command' => @conf['command_run'],
      'uris' => @conf['uris'],
      'date' => Time.now,
      'reports' => @reports,
      'graphs' => @graphs,
      'output_file' => @conf["output_file"],
      'output_dir' => @conf["output_dir"],
      'summary_graph' => @summary_graph.to_html,
      'notes' => @conf["notes"]
    })
  end
  
  def graph_renderer_class
    Object.const_get(@conf['graph_renderer'].to_s)
  end
  
end