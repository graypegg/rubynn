# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/node'
require_relative '../../lib/static_node'

RSpec.describe StaticNode do
  it_behaves_like "Node"

  it 'should provide a #value= method' do
    node = described_class.new
    expect(node).to respond_to :value=
  end

  it 'should accept a value as a initialize param' do
    node = described_class.new value: 0.2
    expect(node.value).to eq 0.2
  end

  it 'should default to a bias of 0.0' do
    node = described_class.new value: 0.2
    expect(node.bias).to eq 0.0
  end

  it 'should use a #activation_function that does not affect the result if between 0.0..1.0' do
    input_node = instance_double("Node", value: 1.0, get_weight_for: 0.7)
    node = described_class.new bias: 0.0
    result = node.activate input_node
    expect(result).to eq input_node.value * input_node.get_weight_for(node)
  end

  it 'should use a #activation_function that returns 1.0 if greater than 1.0' do
    input_node = instance_double("Node", value: 2.0, get_weight_for: 1.0)
    node = described_class.new bias: 0.0
    result = node.activate input_node, input_node
    expect(result).to eq 1.0
  end
end
