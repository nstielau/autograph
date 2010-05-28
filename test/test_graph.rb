require File.dirname(__FILE__) + '/test_helper.rb'

class TestGraphSeries < Test::Unit::TestCase
  def setup
  end

  def test_title
    title = "Some Title"
    g = Graph.new(:title => title)
    assert_equal g.title, title
  end

  def test_series_is_empty_by_default
    g = Graph.new()
    assert_equal g.series, []
  end
end