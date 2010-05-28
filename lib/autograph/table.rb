class Table
  attr :rows

  def initialize(column_names)
    @column_names = column_names.map{|n| n.to_s.to_sym}
    @rows = []
  end

  def column(name)
    @rows.map{|r| r[name.to_s.to_sym]}
  end

  def max(name)
    @rows.map{|r| r[name.to_s.to_sym].to_i}.max
  end

  def <<(row_hash)
    # Symbolize keys on the way in
    @rows << row_hash.inject({}){|x,y| x[y[0].to_s.to_sym] = y[1]; x}
  end

  def to_html
    html = "<table>\n";
    html << "  <tr>\n"
    @column_names.each do |key|
      html << "    <th>#{key}</th>\n"
    end
    html << "  </tr>\n"
    rows.each do |r|
      html << "  <tr>\n"
      @column_names.each do |key|
        html << "    <td>#{r[key]}</td>\n"
      end
      html << "  </tr>\n"
    end
    html << "</table>\n"
    html
  end
end