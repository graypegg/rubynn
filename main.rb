# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/node'
require_relative 'lib/static_node'
require_relative 'lib/network'

network = Network.define do
  input StaticNode.new(value: 0.3), StaticNode.new(value: 0.3), StaticNode.new(value: 0.3)
  layer Node.new, Node.new, Node.new, Node.new, Node.new
  output Node.new
end

network.calculate!

training_network = Network.define do
  is_training
  input StaticNode.new(value: 1)
  output StaticNode.new(value: 0)
end

training_network - network