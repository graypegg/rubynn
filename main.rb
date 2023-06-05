# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/node'
require_relative 'lib/input_node'
require_relative 'lib/network'

i = []
i << InputNode.new(value: 0.3)
i << InputNode.new(value: 0.6)
i << InputNode.new(value: 1.0)

a = []
a << Node.new
a << Node.new
a << Node.new
a << Node.new

a.each { |node| node.activate(*i) }

o1 = Node.new

puts o1.activate(*a)
