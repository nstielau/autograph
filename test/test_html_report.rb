require File.dirname(__FILE__) + '/test_helper.rb'

class TestHtmlReport < Test::Unit::TestCase
  require 'mocha'
  require 'autograph'

  def setup
  end

  def test_requires_params
    error = nil
    begin
      HtmlReport.new({})
    rescue => e
      error = e
    end
    assert(!e.nil?)
  end

  def test_uses_defined_output_file
    output_file = HtmlReport.determine_output_file('file.txt', nil)
    assert_equal(output_file, 'file.txt')
  end

  def test_uses_defined_output_dir
    output_file = HtmlReport.determine_output_file(nil, '/opt')
    assert_equal(output_file, '/opt/load_test.html')
  end

  def test_generate_output_file
    File.expects(:exist?).with('./load_test.html').returns(true)
    File.expects(:exist?).with('./load_test_1.html').returns(true)
    File.expects(:exist?).with('./load_test_2.html').returns(false)
    output_file = HtmlReport.determine_output_file(nil, '.')
    assert_equal(output_file, './load_test_2.html')
  end

end
