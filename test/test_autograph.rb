require File.dirname(__FILE__) + '/test_helper.rb'

class TestAutograph < Test::Unit::TestCase
  require 'mocha'

  def setup
  end
  
  def test_truth
    assert(true)
  end
  
  # def test_uniq_uris
  #   runner = AutoPerf.new(:host => 'example.com')
  #   AutoPerf.any_instance.expects(:generate_graphs)
  #   runner.expects(:generate_graphs)
  # end
end
