# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/node'
require_relative 'lib/input_node'
require_relative 'lib/network'

Network.define do
  layer InputNode.new(value: 0.3), InputNode.new(value: 0.3), InputNode.new(value: 0.3)
  layer Node.new, Node.new, Node.new, Node.new, Node.new
  layer Node.new, Node.new
end
