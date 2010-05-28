$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'optparse'
require 'pp'

require 'autograph/autoperf'
require 'autograph/configuration'
require 'autograph/graph'
require 'autograph/graph_series'
require 'autograph/html_report'
require 'autograph/table'
