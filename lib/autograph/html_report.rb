class HtmlReport
  require 'erb'

  def initialize(reports, graphs, configuration)
    date = Time.now
    host = configuration['host']
    uris = configuration['uris']
    command_run = configuration["command_run"]
    notes = configuration["notes"]

    output_file = HtmlReport.determine_output_file(configuration['output_file'], configuration['output_dir'])

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