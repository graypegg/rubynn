# frozen_string_literal: true

require 'rspec'

RSpec.shared_examples "Node" do
  it 'should accept an initial weight and bias that cannot be changed' do
    node = described_class.new weight: 0.5, bias: 0.1

    expect(node.weight).to eq 0.5
    expect(node).not_to respond_to :weight=
    expect(node.bias).to eq 0.1
    expect(node).not_to respond_to :bias=
  end

  it 'should not accept an initial weight outside of -1.0..1.0' do
    expect {
      described_class.new weight: -1.1, bias: 0.1
    }.to raise_error Node::PropertyOutsideRangeError
  end

  it 'should not accept an initial bias outside of -1.0..1.0' do
    expect {
      described_class.new weight: 0.1, bias: 1.1
    }.to raise_error Node::PropertyOutsideRangeError
  end

  it 'should have the initial value of nil' do
    node = described_class.new weight: 0.5, bias: 0.1

    expect(node.value).to eq nil
  end

  it 'should return the value as a string when to_s is called' do
    node = described_class.new weight: 0.5, bias: 0.2
    node.activate instance_double("Node", value: 0.4)

    expect(node.to_s).to eq node.value.to_s
  end

  describe '#activate' do
    let(:weight) { 0.5 }
    let(:bias) { 1.0 }
    subject { described_class.new(weight:, bias:) }

    it 'is present' do
      expect(subject).to respond_to :activate
    end

    context 'when called' do
      let(:input_1) { instance_double("Node", value: 0.5) }
      let(:input_2) { instance_double("Node", value: 1.0) }
      let(:input_3) { instance_double("Node", value: 0.6) }
      let(:expected) {
        subject.class.activation_function(
          (weight * input_1.value) +
            (weight * input_2.value) +
            (weight * input_3.value) +
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
        parent_node.activate double(:input_random, value: 1.0), double(:input_random, value: 1.0)

        1000.times.each {
          result = parent_node.activate parent_node

          expect(result).to be_between(0.0, 1.0)
        }
      end
    end
  end
end
