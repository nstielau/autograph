require File.dirname(__FILE__) + '/test_helper.rb'

class TestGraphSeries < Test::Unit::TestCase
  require 'mocha'
  require 'autograph'
  
  def setup
  end
  
  def test_constructor
    x_values = [1,2,3]
    y_values = [4,5,6]
    
    gs = GraphSeries.new(:type, x_values, y_values, 'label')
    assert_equal(gs.type, :type)
    assert_equal(gs.x_values, x_values)
    assert_equal(gs.y_values, y_values)
    assert_equal(gs.label, 'label')
  end
  
  def test_constructor_converts_to_floats
    x_values = [1,2,3]
    y_values = [4,5,6]
    
    gs = GraphSeries.new(:type, x_values, y_values, 'label')
    gs.y_values.each{|y| assert_equal(y.class, Float) }
    gs.x_values.each{|x| assert_equal(x.class, Float) }
  end

end
