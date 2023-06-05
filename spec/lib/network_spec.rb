# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/node'
require_relative '../../lib/static_node'
require_relative '../../lib/network'

RSpec.describe Network do
  describe "Network#define" do
    it 'should accept at least 2 layers of Nodes and expose an array of Layers' do
      network = described_class.define do
        input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
        output Node.new, Node.new
      end

      expect(network).to respond_to :layers
      expect(network.layers).to be_a_kind_of Array
      expect(network.layers.length).to eq 2
    end

    it 'should create input layers' do
      network = described_class.define do
        input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
        output Node.new, Node.new
      end

      expect(network.layers[0]).to be_a_kind_of NetworkLayer
      expect(network.layers[0].io_mode).to eq :input
    end

    it 'should always create input layers in layer 0' do
      network = described_class.define do
        layer Node.new
        input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
        output Node.new, Node.new
      end

      expect(network.layers[0]).to be_a_kind_of NetworkLayer
      expect(network.layers[0].io_mode).to eq :input
      expect(network.layers[1]).to be_a_kind_of NetworkLayer
      expect(network.layers[1].io_mode).to be_nil
    end

    it 'should create output layers' do
      network = described_class.define do
        input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
        output Node.new, Node.new
      end

      expect(network.layers[1]).to be_a_kind_of NetworkLayer
      expect(network.layers[1].io_mode).to eq :output
    end

    it 'should create normal layers' do
      network = described_class.define do
        input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
        layer Node.new
        output Node.new, Node.new
      end

      expect(network.layers[1]).to be_a_kind_of NetworkLayer
      expect(network.layers[1].io_mode).to be_nil
    end

    it 'should accept more than 2 layers of Nodes' do
      network = described_class.define do
        input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
        layer Node.new, Node.new
        layer Node.new, Node.new
        output Node.new, Node.new
      end

      expect(network.layers.length).to eq 4
    end

    it 'should only allow one input layer' do
      expect {
        described_class.define do
          input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
          input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
        end
      }.to raise_error Network::DuplicatedIOLayerError
    end

    it 'should only allow one output layer' do
      expect {
        described_class.define do
          input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
          output StaticNode.new, StaticNode.new
          output StaticNode.new, StaticNode.new
        end
      }.to raise_error Network::DuplicatedIOLayerError
    end

    it 'should ignore layers after output layer' do
      network = described_class.define do
        input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
        layer StaticNode.new, StaticNode.new
        output StaticNode.new, StaticNode.new
        layer StaticNode.new, StaticNode.new
      end

      expect(network.layers.length).to eq 3
    end

    it 'should throw if a non-static value input layer is provided' do
      expect {
        described_class.define do
          is_training
          input Node.new
          output Node.new
        end
      }.to raise_error Network::NonStaticInputLayerError
    end

    it 'should not throw if a fully static value input layer is provided' do
      expect {
        described_class.define do
          is_training
          input StaticNode.new(value: 0.0)
          output StaticNode.new(value: 0.0)
        end
      }.not_to raise_error Network::NonStaticInputLayerError
    end

    it 'should throw if a non-static value output layer is provided for training networks' do
      expect {
        described_class.define do
          is_training
          input StaticNode.new(value: 0.0)
          output Node.new
        end
      }.to raise_error Network::BadTrainingNetworkError
    end

    it 'should not throw if a fully static value output layer is provided for training networks' do
      expect {
        described_class.define do
          is_training
          input StaticNode.new(value: 0.0)
          output StaticNode.new(value: 0.0)
        end
      }.not_to raise_error Network::BadTrainingNetworkError
    end

    it 'should require an input layer' do
      expect {
        described_class.define do
          layer StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
          output StaticNode.new, StaticNode.new
        end
      }.to raise_error Network::MissingIOLayerError
    end

    it 'should require an output layer' do
      expect {
        described_class.define do
          input StaticNode.new(value: 0.0), StaticNode.new(value: 0.0)
          layer StaticNode.new, StaticNode.new
        end
      }.to raise_error Network::MissingIOLayerError
    end
  end

  describe '#calculate!' do
    it 'should calculate the final values for the output layer' do
      network = described_class.define do
        input StaticNode.new(value: 0.6), StaticNode.new(value: 0.4)
        layer StaticNode.new(weight: 0.2), StaticNode.new(weight: -0.1)
        output StaticNode.new(weight: 0.5), StaticNode.new(weight: 0.25)
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
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(weight: 0.5), StaticNode.new(weight: 0.5)
      end

      network_2 = described_class.define do
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(weight: 0.75), StaticNode.new(weight: 1.0)
      end

      network_1.calculate!
      network_2.calculate!

      expect_any_instance_of(NetworkLayer).to receive(:-).once.and_return(0)
      network_1 - network_2
    end

    it 'should not calculate the error between networks that have not been calculated' do
      network_1 = described_class.define do
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(weight: 0.5), StaticNode.new(weight: 0.5)
      end

      network_2 = described_class.define do
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(weight: 0.75), StaticNode.new(weight: 1.0)
      end

      network_2.calculate!

      expect_any_instance_of(NetworkLayer).not_to receive(:-)
      expect_any_instance_of(NetworkLayer).to receive(:calculated?).once.and_return(false)
      expect {
        network_1 - network_2
      }.to raise_error Network::IncompatibleNetworksError
    end

    it 'should throw error if trying to calculate the difference between mismatched output layers' do
      network_1 = described_class.define do
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(weight: 0.5), StaticNode.new(weight: 0.5)
      end

      network_2 = described_class.define do
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(weight: 1.0), StaticNode.new(weight: 1.0), StaticNode.new(weight: 1.0)
      end

      network_1.calculate!
      network_2.calculate!

      expect_any_instance_of(NetworkLayer).not_to receive(:-)
      expect {
        network_1 - network_2
      }.to raise_error Network::IncompatibleNetworksError
    end

    it 'should throw error if trying to calculate the difference between mismatched input layers' do
      network_1 = described_class.define do
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(weight: 0.5), StaticNode.new(weight: 0.5)
      end

      network_2 = described_class.define do
        input StaticNode.new(value: 1.0)
        output StaticNode.new(weight: 1.0), StaticNode.new(weight: 1.0)
      end

      network_1.calculate!
      network_2.calculate!

      expect_any_instance_of(NetworkLayer).not_to receive(:-)
      expect {
        network_1 - network_2
      }.to raise_error Network::IncompatibleNetworksError
    end

    it 'should calculate the error between a calculated network and a training network' do
      network_1 = described_class.define do
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(weight: 0.5), StaticNode.new(weight: 0.5)
      end

      network_2 = described_class.define do
        is_training
        input StaticNode.new(value: 1.0), StaticNode.new(value: 0.0)
        output StaticNode.new(value: 1.0), StaticNode.new(value: 1.0)
      end

      network_1.calculate!

      expect_any_instance_of(NetworkLayer).to receive(:-).once.and_return(0)
      network_1 - network_2
    end
  end
end
