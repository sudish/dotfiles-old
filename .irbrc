# -*-ruby-*-
#
# Started from Phil Hagelberg's .irbrc at
# git://github.com/technomancy/dotfiles.git

require 'rubygems'
require 'pp'

begin
  require 'bond'
  Bond.start
  # For users using a pure ruby readline
  #Bond.start :readline => :ruby
rescue LoadErr => e
  require 'irb/completion'
end

begin
  require 'hirb'
  Hirb.enable
  require 'utility_belt'
  require 'looksee'
  require 'wirble'
  Wirble.init
  Wirble.colorize
rescue LoadError
end

# Inspecting really long strings causes inf-ruby to get really, really slow.
# class String
#   def inspect
#     puts self
#   end
# end

IRB.conf[:AUTO_INDENT]=true
