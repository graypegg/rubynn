# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/node'
require_relative '../../lib/static_node'
require_relative '../../lib/network_layer'

RSpec.describe NetworkLayer do
  it 'should output a string of all values in a layer when to_s is called' do
    expect_any_instance_of(StaticNode).to receive(:to_s).once.and_return "StaticNode RESPONSE"
    output_layer = described_class.new(nodes: [
      StaticNode.new(value: 1.0),
    ], io_mode: :output)

    expect(output_layer.to_s).to eq ["StaticNode RESPONSE"].to_s
  end

  it 'should respond to length with the length of the nodes array' do
    output_layer = described_class.new(nodes: [
      instance_double("Node", value: 1.0),
      instance_double("Node", value: 0.0),
    ], io_mode: :output)

    expect(output_layer.length).to eq 2
  end

  it 'should respond to #calculated? with true if all nodes have a value' do
    layer = described_class.new(nodes: [
      instance_double("Node", value: 1.0),
      instance_double("Node", value: 0.0),
    ])

    expect(layer.calculated?).to eq true
  end

  it 'should respond to #calculated? with false if any node is missing a value' do
    layer = described_class.new(nodes: [
      instance_double("Node", value: nil),
      instance_double("Node", value: 1.0),
    ])

    expect(layer.calculated?).to eq false
  end

  it 'should respond to #- with the error between two layers' do
    training_layer = described_class.new(nodes: [
      instance_double("Node", value: 1.0),
      instance_double("Node", value: 0.2)
    ], io_mode: :output)

    learning_layer = described_class.new(nodes: [
      instance_double("Node", value: 0.5),
      instance_double("Node", value: 0.75)
    ], io_mode: :output)

    error = training_layer - learning_layer
    expect(error).to eq 0.5525
  end
end
