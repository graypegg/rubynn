# frozen_string_literal: true

require 'rspec'

RSpec.shared_examples "Node" do
  it 'should accept an initial that cannot be changed' do
    node = described_class.new bias: 0.1

    expect(node.bias).to eq 0.1
    expect(node).not_to respond_to :bias=
  end

  it 'should not accept an initial bias outside of -1.0..1.0' do
    expect {
      described_class.new bias: 1.1
    }.to raise_error Node::PropertyOutsideRangeError
  end

  it 'should have the initial value of nil' do
    node = described_class.new bias: 0.1

    expect(node.value).to eq nil
  end

  it 'should return the value as a string when to_s is called' do
    node = described_class.new bias: 0.2
    node.activate instance_double("Node", value: 0.4, get_weight_for: 1.0)

    expect(node.to_s).to eq node.value.to_s
  end

  describe '#activate' do
    let(:bias) { 1.0 }
    subject { described_class.new(bias:) }

    it 'is present' do
      expect(subject).to respond_to :activate
    end

    context 'when called' do
      let(:input_1) { instance_double("Node", value: 0.5, get_weight_for: 0.75) }
      let(:input_2) { instance_double("Node", value: 1.0, get_weight_for: 0.5) }
      let(:input_3) { instance_double("Node", value: 0.6, get_weight_for: 0.25) }
      let(:expected) {
        subject.class.activation_function(
          (input_1.get_weight_for(subject) * input_1.value) +
            (input_2.get_weight_for(subject) * input_2.value) +
            (input_3.get_weight_for(subject) * input_3.value) +
            bias
        )
      }

      it 'should respond with combined value factoring in the nodes weight, bias, and activation function' do
        result = subject.activate input_1, input_2, input_3
        expect(result).to eq expected
      end

      it 'should update value' do
        subject.activate input_1, input_2, input_3
        expect(subject.value).to eq expected
      end

      it 'should always return value between 0 and 1' do
        parent_node = subject
        parent_node.activate instance_double('Node', value: 2.0, get_weight_for: 1.0)

        1000.times.each {
          result = parent_node.activate parent_node

          expect(result).to be_between(0.0, 1.0)
        }
      end
    end
  end
end
