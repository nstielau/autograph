def rasterize_graphs
  batik_location = @conf['batik-rasterizer-jar']
  if File.exist?(batik_location)
    `java -jar #{batik_location} *.svg > /dev/null 2>&1`
  
    Dir.glob('*.png').each do |png|
      if File.size(png) > 0
        File.delete(png.sub('.png', '.svg'))
      else
        puts "Error rasterizing #{png}, leaving SVG intact."
      end
    end
    
    @graphs.each do |uri, graph|
      @graphs[uri].each do |file_name|
        @graphs[uri] = @graphs[uri].map{|x| File.exist?(x.sub('.svg', '.png')) ? x.sub('.svg', '.png') : x}  
      end
    end
  end
end