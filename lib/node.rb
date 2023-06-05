# frozen_string_literal: true

class Node
  attr_reader :weight, :bias, :value

  class << self
    def activation_function(x)
      1 / (1 + Math.exp(-1 * (x - 0.5)))
    end
  end

  class PropertyOutsideRangeError < StandardError; end
  VALID_RANGE = -1.0..1.0

  def initialize(weight: rand(VALID_RANGE), bias: rand(VALID_RANGE))
    raise PropertyOutsideRangeError, "weight=#{weight} is not in range of -1.0..1.0" unless weight.between?(-1.0, 1.0)
    raise PropertyOutsideRangeError, "bias=#{bias} is not in range of -1.0..1.0" unless bias.between?(-1.0, 1.0)

    @weight = weight
    @bias = bias
    @value = nil
  end

  def activate(*inputs)
    weighted_sum = inputs.reduce(0.0) { |out, inp| out + (inp.value * weight) }
    output = self.class.activation_function(weighted_sum + bias)
    @value = output
    output
  end
end
