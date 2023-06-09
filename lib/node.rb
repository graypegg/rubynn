# frozen_string_literal: true

class Node
  attr_reader :bias, :value

  class << self
    def activation_function(x)
      1 / (1 + Math.exp(-1 * (x - 0.5)))
    end
  end

  class PropertyOutsideRangeError < StandardError; end
  VALID_RANGE = -1.0..1.0

  def initialize(bias: rand(VALID_RANGE))
    raise PropertyOutsideRangeError, "bias=#{bias} is not in range of -1.0..1.0" unless bias.between?(-1.0, 1.0)

    @weights = {}
    @bias = bias
    @value = nil
  end

  def activate(*inputs)
    weighted_sum = inputs.reduce(0.0) { |out, inp| out + (inp.value * inp.get_weight_for(self)) }
    output = self.class.activation_function(weighted_sum + bias)
    @value = output
    output
  end

  def to_s
    value.to_s
  end

  def get_weight_for(node)
    @weights[node] = rand(VALID_RANGE) if @weights[node].nil?
    @weights[node]
  end
end
