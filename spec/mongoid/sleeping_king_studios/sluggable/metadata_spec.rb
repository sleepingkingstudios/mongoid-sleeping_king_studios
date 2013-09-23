# spec/mongoid/sleeping_king_studios/sluggable/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/sluggable/metadata'

describe Mongoid::SleepingKingStudios::Sluggable::Metadata do
  let(:name)       { :sluggable }
  let(:attribute)  { :title }
  let(:properties) { { :attribute => attribute } }
  let(:instance)   { described_class.new name, properties }

  describe '#value_to_slug' do
    specify { expect(instance).to respond_to(:value_to_slug).with(1).arguments }

    context 'with nil' do
      specify 'returns an empty string' do
        expect(instance.value_to_slug nil).to be == ''
      end # specify
    end # context

    context 'with an empty string' do
      specify 'returns an empty string' do
        expect(instance.value_to_slug '').to be == ''
      end # specify
    end # context

    context 'with a mixed-case string' do
      specify 'returns the downcased string' do
        expect(instance.value_to_slug 'Athena').to be == 'athena'
      end # specify
    end # context

    context 'with a string with whitespace' do
      specify 'returns the string with whitespace replaced with hyphens' do
        expect(instance.value_to_slug 'Galactic Ley Line').to be == 'galactic-ley-line'
      end # specify
    end # context

    context 'with a string with URL-unfriendly characters' do
      specify 'returns the sanitized string' do
        expect(instance.value_to_slug 'Zweihänder').to be == 'zweihander'
      end # specify
    end # context
  end # describe

  describe '#attribute' do
    specify { expect(instance).to respond_to(:attribute).with(0).arguments }
    specify { expect(instance.attribute).to be == attribute }

    describe '#[]' do
      let(:value) { :name }

      specify 'changes value' do
        expect {
          instance[:attribute] = value
        }.to change(instance, :attribute).to(value)
      end # specify
    end # describe

    context 'with a String value' do
      let(:attribute)  { 'label' }

      specify 'returns a Symbol' do
        expect(instance.attribute).to be == attribute.intern
      end # specify
    end # context
  end # describe

  describe '#attribute?' do
    specify { expect(instance).to respond_to(:attribute?).with(0).arguments }
    specify { expect(instance.attribute?).to be true }

    describe '#[]' do
      let(:value) { nil }

      specify 'changes value' do
        expect {
          instance[:attribute] = value
        }.to change(instance, :attribute?).to(false)
      end # specify
    end # describe
  end # describe

  describe '#lockable?' do
    specify { expect(instance).to respond_to(:lockable?).with(0).arguments }
    specify { expect(instance.lockable?).to be false }

    describe '#[]' do
      let(:value) { true }

      specify 'changes value' do
        expect {
          instance[:lockable] = value
        }.to change(instance, :lockable?).to(true)
      end # specify
    end # describe
  end # describe
end # describe
