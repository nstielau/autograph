class Table
  attr :rows

  def initialize
    @rows = []
  end

  def column(name)
    @rows.map{|r| r[name]}
  end

  def <<(row_hash)
    @rows << row_hash
  end
end