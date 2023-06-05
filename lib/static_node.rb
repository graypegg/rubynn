# frozen_string_literal: true

class StaticNode < Node
  attr_writer :value

  class << self
    def activation_function(x)
      return 1.0 if x > 1.0
      x
    end
  end

  def initialize(value: nil, weight: 1.0, bias: 0.0)
    super(weight:, bias:)
    @value = value
  end
end
