# spec/mongoid/sleeping_king_studios/has_tree/errors/missing_ancestor_error_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors/missing_ancestor_error'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/metadata'

RSpec.describe Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError do
  describe 'constructor' do
    specify { expect(described_class).to construct.with(3).arguments }
  end # describe

  let(:base) { Mongoid::SleepingKingStudios::Support::Models::Sluggable::Slug }
  let(:metadata) do
    Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Metadata.new :test_concern
  end # let
  let(:expected) { [] }
  let(:options)  { {} }
  let(:instance) { described_class.new base, metadata, expected, **options }

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

  describe '#message' do
    let(:expected) { %i(able baker charlie) }
    let(:problem) do
      "Ancestor not found for #{metadata.foreign_key} #{expected.inspect}."
    end # let
    let(:message) { "Problem:\n  #{problem}" }

    specify { expect(instance).to respond_to(:message).with(0).arguments }
    specify { expect(instance.message).to be == message }
  end # describe
end # describe
