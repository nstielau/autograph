require File.dirname(__FILE__) + '/test_helper.rb'

class TestGraphSeries < Test::Unit::TestCase
  def setup
  end

  def test_column_returns_array
    assert_equal Table.new.column(:some_key).class, Array
  end

  def test_column_returns_empty_array_by_default
    assert_equal Table.new.column(:some_key).size, 0
  end

  def test_column_with_multiple_rows
    one   = {:a => 1, :b => 222}
    two   = {:a => 11, :b => 22}
    three = {:a => 111, :b => 2}
    t = Table.new
    t << one
    t << two
    t << three
    assert_equal t.column(:a), [1,11,111]
  end

  def test_adding_rows
    t = Table.new
    t << {:a => 1, :b => 2}
    assert_equal t.column(:a).size, 1
  end

  def test_adding_rows_with_missing_key_adds_nil_value
    t = Table.new
    t << {:a => 1, :b => 2}
    assert_equal t.column(:c).size, 1
    assert_equal t.column(:c).first, nil
  end

  def test_multiple_rows_are_ordered
    one   = {:a => 1, :b => 222}
    two   = {:a => 11, :b => 22}
    three = {:a => 111, :b => 2}
    t = Table.new
    t << one
    t << two
    t << three
    assert_equal t.rows[0], one
    assert_equal t.rows[1], two
    assert_equal t.rows[2], three
  end
end