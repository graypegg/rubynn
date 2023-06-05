# frozen_string_literal: true

class Network
  attr_accessor :layers

  def initialize
    @layers = []
    @type = :learning
  end

  def has_io_layer?(mode)
    !get_io_layer(mode).nil?
  end

  def get_io_layer(mode)
    layers.find { |layer| layer.io_mode == mode }
  end

  def calculate!
    input_layer = get_io_layer :input

    layers[1..].reduce(input_layer) do |last_layer, layer|
      layer.nodes.each do |node|
        node.activate(*last_layer.nodes)
      end
      layer
    end
  end

  def -(other)
    self_output = get_io_layer :output
    other_output = other.get_io_layer :output

    self_output.nodes.each do |self_node|

    end
  end

  class << self
    def define(&block)
      network = Network.new
      network.instance_eval(&block)
      raise MissingIOLayerError, "#{network} is missing an input layer" unless network.has_io_layer? :input
      raise MissingIOLayerError, "#{network} is missing an output layer" unless network.has_io_layer? :output
      network
    end
  end

  class NetworkLayer
    attr_accessor :nodes, :io_mode

    def initialize(nodes:, io_mode: nil)
      @nodes = nodes
      @io_mode = io_mode
    end
  end

  class DuplicatedIOLayerError < StandardError; end
  class MissingIOLayerError < StandardError; end

  private

  def input(*nodes)
    io_layer :input, *nodes
  end

  def output(*nodes)
    io_layer :output, *nodes
  end

  def io_layer(mode, *nodes)
    if has_io_layer?(mode)
      raise DuplicatedIOLayerError, "A #{mode} layer already exists on #{self}"
    end

    layer = NetworkLayer.new(nodes:)
    layer.io_mode = mode
    case mode
    when :input
      layers.unshift(layer)
    when :output
      layers.push(layer)
    end
    layer
  end

  def layer(*nodes)
    return if has_io_layer? :output
    layers << NetworkLayer.new(nodes:)
    layers.last
  end

  def is_training
    @type = :training
  end

end
