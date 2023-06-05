# frozen_string_literal: true

require_relative 'network_layer'

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

  def calculated?
    output_layer = get_io_layer :output
    output_layer.calculated?
  end

  def calculate!
    input_layer = get_io_layer :input

    # TODO: Move the layer.nodes.each call into NetworkLayer. Replace tests for this with a mock check
    layers[1..].reduce(input_layer) do |last_layer, layer|
      layer.nodes.each do |node|
        node.activate(*last_layer.nodes)
      end
      layer
    end
  end

  def -(learning_network)
    raise IncompatibleNetworksError, "#{self} has not been calculated and thus cannot be used as the training network" unless calculated?
    raise IncompatibleNetworksError, "#{learning_network} has not been calculated and thus cannot be used as the learning network" unless learning_network.calculated?

    learning_layer = learning_network.get_io_layer :output
    training_layer = get_io_layer :output

    if (learning_layer.length != training_layer.length)
      raise IncompatibleNetworksError, "#{learning_layer} (dimension #{learning_layer.length}) can not be compared with #{training_layer} (dimension #{training_layer.length})"
    end

    training_layer - learning_layer
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

  class DuplicatedIOLayerError < StandardError; end
  class MissingIOLayerError < StandardError; end
  class IncompatibleNetworksError < StandardError; end

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
