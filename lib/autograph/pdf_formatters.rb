require 'pdf/writer'
require 'pdf/charts'
require 'pdf/charts/stddev'

require "rubygems"
require "ruport"

require "ruport/util"

require "scruffy"


module StandardPDFReport

  def build_standard_report_header
    pdf_writer.select_font("Times-Roman")

    options.text_format = { :font_size => 14, :justification => :left }

    add_text "<i>Delve Networks</i>"
    add_text "<i>#{options.report_title}</i>" 
    add_text "Generated at #{Time.now.strftime('%H:%M on %Y-%m-%d')}" 

    # center_image_in_box "ruport.png", :x => left_boundary, 
    #                                   :y => top_boundary - 50,
    #                                   :width => 275,
    #                                   :height => 70

    move_cursor_to top_boundary - 80

    pad_bottom(20) { hr }

    options.text_format[:justification] = :left
    options.text_format[:font_size] = 12
  end

  def finalize_standard_report
    render_pdf
    pdf_writer.save_as(options.file)
  end

end

class DocumentController < Ruport::Controller
  stage :standard_report_header, :document_body
  finalize :standard_report
end

class FormatterForPDF < Ruport::Formatter::PDF

  renders :pdf, :for => [DocumentController]

  include StandardPDFReport

  build :document_body do
    pad(10) { add_text "Load analysis\n"}
    hr()
    
    data.each do |table| 
      pad(10) { add_text(table[:title])} 
      pad(10) { add_text(table[:description])} 
      
      chart = ::PDF::Charts::StdDev.new 

      data_table = table[:table]
      plot_field = table[:plot]
      vary_field = table[:vary]

      graph = Graph(data_table.column(vary_field).map{|x| x.to_i})
      graph.series data_table.column(plot_field).map{|x| x.to_f}, "Accepted Connections"
      graph.series data_table.column("req/s").map{|x| x.to_f}, "Achieved Requests/Second" 
      graph.save_as("requests_graph.svg")

      idx = 0
      data_table.column(plot_field).each do |to_plot|
        label = data_table.column(vary_field)[idx].to_s
        datum = to_plot.to_f
        puts "Plotting '#{label}' @ #{datum}"
        chart.data << ::PDF::Charts::StdDev::DataPoint.new(label, datum, 0)
        idx = idx + 1
      end
      
      puts "Chart data is #{chart.data.inspect}"

      max = data_table.column(plot_field).max.to_i
      step = (data_table.column(plot_field)[1].to_i - data_table.column(plot_field)[0].to_i)
      puts "step is #{step}"
      puts "Max is #{max}"
      puts "To plot is '#{plot_field}'"
      puts "To vary is '#{vary_field}'"
      puts "Plots are #{data_table.column(plot_field).inspect}"
      puts "Varies are #{data_table.column(vary_field).inspect}"
      puts "Reqs are #{data_table.column('req/s').inspect}"
       ::PDF::Charts::StdDev::Scale.new do |scale| 
         scale.range               = 0..((max + max * 0.1).to_i)
         scale.step                = 1#step
         scale.style               = ::PDF::Writer::StrokeStyle.new(0.25) 
         scale.show_labels         = false 
         ::PDF::Charts::StdDev::Label.new do |label| 
           label.text_size         = 8 
           label.text_color        = Color::RGB::Black 
           label.pad               = 2 
           label.decimal_precision = 1
           scale.label             = label 
         end 
         chart.scale               = scale 
       end
       
       chart.height          = 300 
       chart.maximum_width   = 700 
       chart.datapoint_width = 35

       chart.render_on(pdf_writer)
       
      hr()
      
      pad(10) { draw_table(data_table) }
      
      hr()
    end
    
  end
end
