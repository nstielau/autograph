require File.dirname(__FILE__) + '/test_helper.rb'

class TestGraphSeries < Test::Unit::TestCase
  COLUMN_NAMES = [:column_a, :column_b]

  def setup
  end

  def test_column_returns_array
    assert_equal Table.new(COLUMN_NAMES).column(:some_key).class, Array
  end

  def test_column_returns_empty_array_by_default
    assert_equal Table.new(COLUMN_NAMES).column(:some_key).size, 0
  end

  def test_column_with_multiple_rows
    one   = {:column_a => 1, :column_b => 222}
    two   = {:column_a => 11, :column_b => 22}
    three = {:column_a => 111, :column_b => 2}
    t = Table.new(COLUMN_NAMES)
    t << one
    t << two
    t << three
    assert_equal t.column(:column_a), [1,11,111]
  end

  def test_column_with_string_keys
    one   = {:column_b => 2}
    two   = {'column_b' => 222}
    t = Table.new(COLUMN_NAMES)
    t << one
    t << two
    assert_equal t.column(:column_b), [2,222]
  end

  def test_to_html_returns_string
    assert_equal Table.new(COLUMN_NAMES).to_html.class, String
  end

  def test_to_html_header
    html = Table.new(COLUMN_NAMES).to_html
    assert html.match(Regexp.new(COLUMN_NAMES.join(".*"), Regexp::MULTILINE))
  end


  def test_to_html_contains_correct_tds
    t = Table.new(COLUMN_NAMES)
    t << {:column_a => 1, :column_b => 222}
    t << {:column_a => 111, :column_b => 2}
    assert t.to_html.match(/<td>1<\/td>/)
    assert t.to_html.match(/<td>111<\/td>/)
    assert t.to_html.match(/<td>2<\/td>/)
    assert t.to_html.match(/<td>222<\/td>/)
  end

  def test_adding_rows
    t = Table.new(COLUMN_NAMES)
    t << {:column_a => 1, :column_b => 2}
    assert_equal t.column(:column_a).size, 1
  end

  def test_adding_rows_with_missing_key_adds_nil_value
    t = Table.new(COLUMN_NAMES)
    t << {:column_a => 1, :column_b => 2}
    assert_equal t.column(:c).size, 1
    assert_equal t.column(:c).first, nil
  end

  def test_multiple_rows_are_ordered
    one   = {:column_a => 1, :column_b => 222}
    two   = {:column_a => 11, :column_b => 22}
    three = {:column_a => 111, :column_b => 2}
    t = Table.new(COLUMN_NAMES)
    t << one
    t << two
    t << three
    assert_equal t.rows[0], one
    assert_equal t.rows[1], two
    assert_equal t.rows[2], three
  end
end