# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/node'

RSpec.describe Node do
  it_behaves_like "Node"

  it 'should not provide a #value= method' do
    node = described_class.new
    expect(node).not_to respond_to :value=
  end

  it 'should determine a random bias if no bias is provided' do
    expect_any_instance_of(described_class).to receive(:rand).once.and_return(rand)
    node = described_class.new

    expect(node.bias).not_to eq nil
  end
end
