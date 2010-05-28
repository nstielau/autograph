require File.dirname(__FILE__) + '/test_helper.rb'

class TestHtmlReport < Test::Unit::TestCase

  def test_takes_a_hash
    c = Configuration.new(:a => 1)
    assert_equal c[:a], 1
  end

  def test_has_defaults
    c = Configuration.new()
    assert_equal c['low_rate'], 5
  end

  def test_can_override_defaults
    c = Configuration.new('low_rate' => 1)
    assert_equal c['low_rate'], 1
  end

  def test_pretty_print_returns_a_string
    c = Configuration.new().pretty_print
    assert_equal c.class, String
  end
end