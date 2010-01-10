module Autograph
  class HtmlReport
    def initialize(options)
      %w(host uris command notes reports graphs summary_graph output_file output_dir).each do |k|
        raise("Must specify '#{k}' in order to generate a report") unless options.key?(k)
      end
      
      host = options['host']
      title = "Report for #{host}"
      uris = options['uris']
      date = Time.now
      reports = options['reports']
      graphs = options['graphs']
      command_run = options["command_run"]
      summary_graph = options['summary_graph'].to_html if options['summary_graph']
      notes = options["notes"]

      output_file = self.determine_output_file(options['output_file'], options['output_dir'])

      template = File.read(File.dirname(__FILE__) + '/report.html.erb')
      result = ERB.new(template).result(binding).to_s 

      File.open(output_file, "w") do |file|
        file.puts result
      end
    end

    def self.determine_output_file(output_file, output_dir)
      return output_file if output_file
      file = File.join(output_dir, "load_test.html")
      i = 0
      while File.exist?(file) do
        i = i + 1
        file = File.join(output_dir, "load_test_#{i}.html")
      end
      file
    end
  end
end
