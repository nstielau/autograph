class Configuration
  def initialize(opts={})
    @conf = {'httperf_num-conns' => 100,
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

    puts pretty_print if opts['verbose']

    @conf
  end

  def [](prop)
    @conf[prop]
  end

  def []=(prop, value)
    @conf[prop] = value
  end

  def merge(other_hash)
    @conf.dup.merge(other_hash)
  end

  def inspect
    @conf.inspect
  end

  def pretty_print
    io = StringIO.new
    io.puts
    io.puts "Using these parameters:"
    @conf.sort.each{ |k, v| io.puts "  #{k}=#{v}"}
    io.puts
    io.read
  end
end