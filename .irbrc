# -*-ruby-*-
#
# Started from Phil Hagelberg's .irbrc at
# git://github.com/technomancy/dotfiles.git

require 'irb/completion'
require 'rubygems'
require 'pp'

begin
  # load wirble
  require 'wirble'

  # start wirble (with color)
  Wirble.init
  Wirble.colorize
rescue LoadError => err
  #warn "Couldn't load Wirble: #{err}"
end

def profile
  t = Time.now
  yield
  "Took #{Time.now - t} seconds."
end

# Inspecting really long strings causes inf-ruby to get really, really slow.
# class String
#   def inspect
#     puts self
#   end
# end

IRB.conf[:AUTO_INDENT]=true
