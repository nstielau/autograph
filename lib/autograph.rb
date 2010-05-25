$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'optparse'
require 'ruport'
require 'pp'

require 'autograph/autoperf'
require 'autograph/graph_series'
require 'autograph/html_report'
require 'autograph/configuration'

require 'autograph/graph_renderers/base_renderer'
require 'autograph/graph_renderers/gchart_renderer'
require 'autograph/graph_renderers/scruffy_renderer'
require 'autograph/graph_renderers/flot_renderer'
