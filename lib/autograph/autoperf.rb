class AutoPerf
  COLUMN_NAMES = ['rate', 'conn/s', 'req/s', 'replies/s avg', 'errors', 'net io (KB/s)', 'reply time']

  def initialize(opts = {})
    conf = Configuration.new(opts)

    if conf['use_test_data']
      reports = load_test_data(conf)
    else
      reports = run_tests(conf)
    end

    graphs = generate_graphs(reports, conf)
    HtmlReport.new(reports, graphs, conf)
  end

  def generate_graphs(reports, configuration)
    graphs = {}
    graphs[:request_rate]     = Graph.new(:title => "Demanded vs. Achieved Request Rate (r/s)")
    graphs[:response_time]    = Graph.new(:title => "Demanded Request Rate (r/s) vs. Response Time")
    graphs[:max_request_rate] = Graph.new(:title => "Maximum Achieved Request Rate")

    reports.each do |uri, report|
      graphs[:request_rate].series  << GraphSeries.new(report.column('rate'), report.column('conn/s').map{|x| x.to_f}, "Request rate for '#{uri}'", uri)
      graphs[:response_time].series << GraphSeries.new(report.column('rate'), report.column('reply time'), "Response time for '#{uri}'", uri)
    end

    reports.keys.each_with_index do |key, index|
      graphs[:max_request_rate].series << GraphSeries.new([index], [reports[key].max('conn/s')], "Max Request Rate for '#{key}'")
    end

    graphs
  end

  def benchmark(conf)
    raise "You must specify a host." if conf['host'].nil?
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

  def vary_rate(uri, configuration)
    puts "Config is #{configuration.inspect}" if configuration['verbose']
    results = {}
    report = Table.new(COLUMN_NAMES)

    (configuration['low_rate']..configuration['high_rate']).step(configuration['rate_step']) do |rate|
      results[rate] = benchmark(configuration.merge({'httperf_rate' => rate, 'httperf_uri' => "'#{uri}'"}))
      report << results[rate].merge({'rate' => rate})

      puts report.to_s
      puts results[rate]['output'] if results[rate]['errors'].to_i > 0
    end

    report
  end

  def run_tests(configuration)
    reports = {}
    configuration['uris'].uniq.each do |uri|
      reports[uri] = vary_rate(uri, configuration)
    end
    reports
  end

  def load_test_data(configuration)
    reports = {}
    configuration['host'] = "127.0.0.1"
    configuration['uris'] = ['/', '/page1', '/page2']
    configuration['uris'].each do |uri|
      reports[uri] = Table.new(COLUMN_NAMES)
      times = [130.7, 132.7, 180.4, 438.3, 591.9, 686.9, 739.4, 661.3, 727.1, 546.5, 711.1, 893.7, 870.0]
      conns = [5.0, 21.5, 28.8, 30.6, 26.3, 24.7, 23.0, 25.8, 28.0, 27.4, 27.9, 22.2, 22.7]
      1.upto(10) do |i|
        reports[uri] << {'rate' => i*10 - 10,
                         'errors' => 0,
                         'conn/s' => conns[((i + rand * 10) % conns.length).to_i],
                         'req/s' => 0,
                         'replies/s avg' => 0,
                         'net io (KB/s)' => 100,
                         'reply time' => times[((i + rand * 10) % times.length).to_i]}
      end
    end
    reports
  end
end