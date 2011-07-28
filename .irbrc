# -*- ruby -*-
#

require 'rubygems'
require 'pp'

module SjIrb
  VERBOSE = true

  PACKAGES = {
    'bond'   => [ lambda { Bond.start }, lambda { require 'irb/completion' } ],
    'wirble' => [ lambda { Wirble.init; Wirble.colorize }, nil ],
    'hirb'   => [ lambda { Hirb.enable }, nil ],
    'looksee' => nil,
    'utility_belt' => nil,
  }

  def SjIrb.load_packages
    loaded = []
    not_loaded = []
    PACKAGES.each_pair do |package, actions|
      # recover from missing packages but let errors in actions
      # terminate processing
      begin
        require package
        actions[0].call unless actions.nil? or actions[0].nil?
        loaded << package
      rescue LoadError
        actions[1].call unless actions.nil? or actions[1].nil?
        not_loaded << package
      end
    end

    if VERBOSE
      puts "irb loaded: #{loaded.inspect}"
      puts "not loaded: #{not_loaded.inspect}"
    end
  end
end

SjIrb.load_packages

# Inspecting really long strings causes inf-ruby to get really, really slow.
# class String
#   def inspect
#     puts self
#   end
# end

IRB.conf[:AUTO_INDENT]=true
