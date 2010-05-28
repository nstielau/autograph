$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'optparse'
require 'ruport'
require 'pp'

require 'autograph/autoperf'
require 'autograph/graph'
require 'autograph/graph_series'
require 'autograph/html_report'
require 'autograph/configuration'
require 'autograph/table'

require 'autograph/graph_renderers/base_renderer'
