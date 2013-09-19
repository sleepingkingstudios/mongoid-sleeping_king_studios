# spec/mongoid/sleeping_king_studios/concern_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/concern'

describe Mongoid::SleepingKingStudios::Concern do
  let(:concern) do
    Mongoid::SleepingKingStudios::Concern.new
  end # let
  let(:described_class) do
    klass = Class.new do
      class << self
        def relations
          @relations ||= {}
        end # class method relations
      end # class << self
    end # class
    klass.send :include, concern
    klass
  end # let
  let(:instance) { described_class.new }

  describe '::characterize' do
    let(:name)       { :concern }
    let(:properties) { {} }

    specify { expect(concern).to respond_to(:characterize).with(2).arguments }
    specify 'returns metadata' do
      expect(concern.characterize name, properties).to be_a Mongoid::SleepingKingStudios::Concern::Metadata
    end # specify

    let(:metadata) { concern.characterize name, properties }

    specify { expect(metadata.name).to be == name }
  end # describe

  describe '::relate' do
    let(:name)       { :concern }
    let(:properties) { {} }
    let(:metadata)   { Mongoid::SleepingKingStudios::Concern::Metadata.new name, properties }

    specify { expect(concern).to respond_to(:relate).with(3).arguments }
    specify 'updates the relations' do
      expect {
        concern.relate described_class, name, metadata
      }.to change(described_class, :relations).to("sleeping_king_studios::#{name}" => metadata)
    end # specify
  end # describe

  describe '::valid_options' do
    specify { expect(concern).to respond_to(:valid_options).with(0).arguments }
    specify { expect(concern.valid_options).to be_a Array }
  end # describe

  describe '::validate_options' do
    let(:name) { :concern }

    specify { expect(concern).to respond_to(:validate_options).with(2).arguments }

    context 'with invalid options' do
      let(:options) { { :defenestrate => true } }

      specify 'raises an error' do
        expect {
          concern.validate_options name, options
        }.to raise_error Mongoid::Errors::InvalidOptions
      end # specify
    end # context
  end # describe
end # describe
