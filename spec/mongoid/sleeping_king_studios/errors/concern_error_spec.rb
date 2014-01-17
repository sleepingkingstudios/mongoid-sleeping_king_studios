# spec/mongoid/sleeping_king_studios/errors/concern_error_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/concern/metadata'
require 'mongoid/sleeping_king_studios/errors/concern_error'

RSpec.describe Mongoid::SleepingKingStudios::Errors::ConcernError do
  describe 'constructor' do
    specify { expect(described_class).to construct.with(2).arguments }
  end # describe

  let(:base) { Mongoid::SleepingKingStudios::Support::Models::Sluggable::Slug }
  let(:metadata) do
    Mongoid::SleepingKingStudios::Concern::Metadata.new :test_concern
  end # let
  let(:instance) { described_class.new base, metadata }

  describe '#message' do
    let(:problem) do
      "An error occurred with the #{metadata.name.to_s.camelize} concern for" +
        " class #{base}."
    end # let
    let(:message) { "Problem:\n  #{problem}" }

    specify { expect(instance).to respond_to(:message).with(0).arguments }
    specify { expect(instance.message).to be == message }

    context 'with metadata options' do
      let(:metadata) do
        Mongoid::SleepingKingStudios::Concern::Metadata.new :custom_concern
      end # let
      let(:message) do
        /An error occurred with the #{metadata.name.to_s.camelize} concern for class #{base}/
      end # let

      specify 'returns the concern name' do
        expect(instance.message).to be =~ message
      end # specify
    end # context

    context 'with a summary, details, and resolution' do
      let(:summary)    { "The issue likely originates with your computer's chair-to-keyboard interface." }
      let(:details)    { "The operation failed with an error code of ID 10-T." }
      let(:resolution) { "Have you tried turning it off and on again?" }
      let(:keywords) do
        { :summary => summary,
          :details => details,
          :resolution => resolution
        } # end object
      end # let
      let(:message) do
        str = "Problem:\n  #{problem}"
        str += "\nSummary:\n  #{summary}"
        str += "\nDetails:\n  #{details}"
        str += "\nResolution:\n  #{resolution}"
      end # let
      let(:instance) { described_class.new base, metadata, problem, **keywords }

      specify 'prints the message with problem, summary, and resolution' do
        expect(instance.message).to be == message
      end # specify
    end # context
  end # describe

  describe '#base' do
    specify { expect(instance).to have_property :base }
    specify { expect(instance.base).to be == base }
  end # describe

  describe '#metadata' do
    specify { expect(instance).to have_property :metadata }
    specify { expect(instance.metadata).to be == metadata }
  end # describe
end # describe
