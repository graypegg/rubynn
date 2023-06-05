# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/node'
require_relative '../../lib/input_node'
require_relative '../../lib/network'

RSpec.describe Network do
  describe "Network#define" do
    it 'should accept at least 2 layers of Nodes and expose an array of Layers' do
      network = described_class.define do
        input InputNode.new, InputNode.new
        output Node.new, Node.new
      end

      expect(network).to respond_to :layers
      expect(network.layers).to be_a_kind_of Array
      expect(network.layers.length).to eq 2
      expect(network.layers[0]).to be_a_kind_of Network::NetworkLayer
    end

    it 'should accept more than 2 layers of Nodes' do
      network = described_class.define do
        input InputNode.new, InputNode.new
        layer Node.new, Node.new
        layer Node.new, Node.new
        output Node.new, Node.new
      end

      expect(network.layers.length).to eq 4
    end

    it 'should only allow one input layer' do
      expect {
        described_class.define do
          input InputNode.new, InputNode.new
          input InputNode.new, InputNode.new
        end
      }.to raise_error Network::DuplicatedIOLayerError
    end

    it 'should only allow one output layer' do
      expect {
        described_class.define do
          input InputNode.new, InputNode.new
          output InputNode.new, InputNode.new
          output InputNode.new, InputNode.new
        end
      }.to raise_error Network::DuplicatedIOLayerError
    end

    it 'should ignore layers after output layer' do
      network = described_class.define do
        input InputNode.new, InputNode.new
        layer InputNode.new, InputNode.new
        output InputNode.new, InputNode.new
        layer InputNode.new, InputNode.new
      end

      expect(network.layers.length).to eq 3
    end

    it 'should require an input layer' do
      expect {
        described_class.define do
          layer InputNode.new, InputNode.new
          output InputNode.new, InputNode.new
        end
      }.to raise_error Network::MissingIOLayerError
    end

    it 'should require an output layer' do
      expect {
        described_class.define do
          input InputNode.new, InputNode.new
          layer InputNode.new, InputNode.new
        end
      }.to raise_error Network::MissingIOLayerError
    end
  end

  describe '#calculate!' do
    it 'should calculate the final values for the output layer' do
      network = described_class.define do
        input InputNode.new(value: 0.6), InputNode.new(value: 0.4)
        layer InputNode.new(weight: 0.2), InputNode.new(weight: -0.1)
        output InputNode.new(weight: 0.5), InputNode.new(weight: 0.25)
      end

      network.calculate!
      output_layer = network.get_io_layer :output

      expect(output_layer.nodes[0].value).to eq 0.05
      expect(output_layer.nodes[1].value).to eq 0.025
    end
  end

  describe '#-' do
    it 'should calculate the error between two calculated networks' do
      network_1 = described_class.define do
        input InputNode.new(value: 1.0), InputNode.new(value: 0.0)
        output InputNode.new(weight: 0.5), InputNode.new(weight: 0.5)
      end

      network_2 = described_class.define do
        input InputNode.new(value: 1.0), InputNode.new(value: 0.0)
        output InputNode.new(weight: 1.0), InputNode.new(weight: 1.0)
      end

      network_1.calculate!
      network_2.calculate!

      error = network_1 - network_2
      expect(error).not_to eq 0
    end

    it 'should throw error if trying to calculate the difference between mismatched output layers' do
      network_1 = described_class.define do
        input InputNode.new(value: 1.0), InputNode.new(value: 0.0)
        output InputNode.new(weight: 0.5), InputNode.new(weight: 0.5)
      end

      network_2 = described_class.define do
        input InputNode.new(value: 1.0), InputNode.new(value: 0.0)
        output InputNode.new(weight: 1.0), InputNode.new(weight: 1.0), InputNode.new(weight: 1.0)
      end

      network_1.calculate!
      network_2.calculate!

      expect {
        network_1 - network_2
      }.to raise_error Network::IncompariableNetworksError
    end

    it 'should calculate the error between a calculated network and a training network' do
      network_1 = described_class.define do
        input InputNode.new(value: 1.0), InputNode.new(value: 0.0)
        output InputNode.new(weight: 0.5), InputNode.new(weight: 0.5)
      end

      network_2 = described_class.define do
        is_training
        input InputNode.new(value: 1.0), InputNode.new(value: 0.0)
        output InputNode.new(value: 1.0), InputNode.new(value: 1.0)
      end

      network_1.calculate!

      error = network_1 - network_2
      expect(error).not_to eq 0
    end
  end
end
