# spec/mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors/unexpected_ancestor_error_spec.rb 

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors/unexpected_ancestor_error'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/metadata'

RSpec.describe Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::UnexpectedAncestorError do
  describe 'constructor' do
    specify { expect(described_class).to construct.with(4).arguments }
  end # describe

  let(:base) { Mongoid::SleepingKingStudios::Support::Models::Sluggable::Slug }
  let(:metadata) do
    Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Metadata.new :test_concern
  end # let
  let(:expected) { [] }
  let(:received) { [] }
  let(:options)  { {} }
  let(:instance) { described_class.new base, metadata, expected, received, **options }

  describe '#expected' do
    specify { expect(instance).to have_property(:expected) }
    specify { expect(instance.expected).to be == expected }

    context 'with a single value' do
      let(:expected) { :foo }

      specify 'returns the value wrapped in an array' do
        expect(instance.expected).to be == [expected]
      end # specify
    end # context

    context 'with an array of values' do
      let(:expected) { %i(able baker charlie) }

      specify 'returns the array' do
        expect(instance.expected).to be == expected
      end # specify
    end # context
  end # describe

  describe '#received' do
    specify { expect(instance).to have_property(:received) }
    specify { expect(instance.received).to be == received }

    context 'with a single value' do
      let(:received) { :foo }

      specify 'returns the value wrapped in an array' do
        expect(instance.received).to be == [received]
      end # specify
    end # context

    context 'with an array of values' do
      let(:received) { %i(able baker charlie) }

      specify 'returns the array' do
        expect(instance.received).to be == received
      end # specify
    end # context
  end # describe

  describe '#message' do
    let(:expected) { %i(able baker charlie) }
    let(:received) { %i(delta echo foxtrot) }
    let(:problem) do
      "Unexpected ancestor(s) found for #{metadata.foreign_key}." +
        "\n" +
        "\n  Expected:" +
        "\n    #{expected.inspect}" +
        "\n  Received:" +
        "\n    #{received.inspect}"
    end # let
    let(:message) { "Problem:\n  #{problem}" }

    specify { expect(instance).to respond_to(:message).with(0).arguments }
    specify { expect(instance.message).to be == message }
  end # describe
end # describe
