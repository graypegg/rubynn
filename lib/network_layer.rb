# frozen_string_literal: true

class NetworkLayer
  attr_accessor :nodes, :io_mode

  def initialize(nodes:, io_mode: nil)
    @nodes = nodes
    @io_mode = io_mode
  end

  def length
    nodes.length
  end

  def to_s
    nodes.map(&:to_s).to_s
  end

  def calculated?
    nodes.all? { |node| !node.value.nil? }
  end

  def -(other)
    nodes.zip(other.nodes).reduce(0) do |sum, nodes|
      training_node = nodes[0]
      learning_node = nodes[1]
      sum + ((training_node.value - learning_node.value) ** 2)
    end
  end
end
