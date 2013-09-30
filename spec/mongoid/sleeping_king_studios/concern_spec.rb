# spec/mongoid/sleeping_king_studios/concern_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/concern'

describe Mongoid::SleepingKingStudios::Concern do
  let(:concern) do
    Module.new do
      extend Mongoid::SleepingKingStudios::Concern
    end # let
  end # let
  let(:described_class) do
    klass = Class.new do
      class << self
        def relations_sleeping_king_studios
          @relations_sleeping_king_studios ||= {}
        end # class method relations_sleeping_king_studios
      end # class << self
    end # class
    klass.send :include, concern
    klass
  end # let
  let(:instance) { described_class.new }

  describe '::characterize' do
    specify { expect(concern).to respond_to(:characterize).with(2..3).arguments }

    let(:name)       { :concern }
    let(:properties) { { :key => :value } }

    let(:metadata) { concern.characterize name, properties }

    specify 'creates the metadata' do
      expect(metadata).to be_a Mongoid::SleepingKingStudios::Concern::Metadata
    end # specify

    specify 'sets the value' do
      concern.characterize name, properties
      expect(metadata[:key]).to be == :value
    end # specify

    context 'with a type specified' do
      let(:type) do
        Class.new(Mongoid::SleepingKingStudios::Concern::Metadata) do
          def key
            self[:key]
          end # method key
        end # class
      end # let

      let(:metadata) { concern.characterize name, properties, type }

      specify 'creates the metadata' do
        expect(metadata).to be_a type
      end # specify

      specify 'sets the value' do
        expect(metadata.key).to be == :value
      end # specify
    end # context
  end # describe

  describe '::relate' do
    let(:name)       { :concern }
    let(:properties) { {} }
    let(:metadata)   { Mongoid::SleepingKingStudios::Concern::Metadata.new name, properties }

    specify { expect(concern).to respond_to(:relate).with(3).arguments }
    specify 'adds the namespace to relations' do
      concern.relate described_class, name, metadata
      expect(described_class).to have_reader :relations_sleeping_king_studios
    end # specify
    specify 'updates the relations' do
      concern.relate described_class, name, metadata
      expect(described_class.relations_sleeping_king_studios).to be == { metadata.relation_key => metadata }
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
