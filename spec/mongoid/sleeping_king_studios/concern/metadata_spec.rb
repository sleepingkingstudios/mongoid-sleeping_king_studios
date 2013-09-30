# spec/mongoid/sleeping_king_studios/concern/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/concern/metadata'

describe Mongoid::SleepingKingStudios::Concern::Metadata do
  let(:name)       { :relation }
  let(:properties) { {} }
  let(:instance)   { described_class.new name, properties }

  describe '#initialize' do
    context 'with empty properties' do
      specify 'has empty values' do
        expect(instance[:key]).to be nil
      end # specify
    end # context

    context 'with set properties' do
      let(:properties) { { :key => :value } }

      specify 'sets the values' do
        expect(instance[:key]).to be == :value
      end # specify
    end # context
  end # describe

  describe '#properties' do
    specify { expect(instance).to respond_to(:properties).with(0).arguments }
    specify { expect(instance.properties).to be_a Hash }

    context 'with set properties' do
      let(:properties) { { :key => :value } }

      specify 'sets the value' do
        expect(instance.properties).to be == properties
      end # specify
    end # context
  end # describe

  describe '#characterize' do
    specify { expect(instance).to respond_to(:characterize).with(2..3).arguments }

    let(:rel_name)       { :property }
    let(:rel_properties) { { :key => :value } }

    let(:rel_metadata) { instance.characterize rel_name, rel_properties }

    specify 'creates the metadata' do
      expect(rel_metadata).to be_a Mongoid::SleepingKingStudios::Concern::Metadata
    end # specify

    specify 'sets the value' do
      expect(rel_metadata[:key]).to be == :value
    end # specify

    context 'with a type specified' do
      let(:rel_type) do
        Class.new(Mongoid::SleepingKingStudios::Concern::Metadata) do
          def key
            self[:key]
          end # method key
        end # class
      end # let

      let(:rel_metadata) { instance.characterize rel_name, rel_properties, rel_type }

      specify 'creates the metadata' do
        expect(rel_metadata).to be_a rel_type
      end # specify

      specify 'sets the value' do
        expect(rel_metadata.key).to be == :value
      end # specify
    end # context
  end # describe

  describe '#[]' do
    specify { expect(instance).to respond_to(:[]).with(1).arguments }
  end # describe

  describe '#[]=' do
    specify { expect(instance).to respond_to(:[]=).with(2).arguments }

    specify 'changes the value' do
      expect {
        instance[:key] = :value
      }.to change {
        instance[:key]
      }.from(nil).to(:value)
    end # specify
  end # describe

  describe '#name' do
    specify { expect(instance).to respond_to(:name).with(0).arguments }
    specify { expect(instance.name).to be == name }
  end # describe

  describe '#relation_key' do
    specify { expect(instance).to respond_to(:relation_key).with(0).arguments }
    specify { expect(instance.relation_key).to be == name.to_s }

    describe '#[]' do
      let(:value) { "prefix::suffix" }

      specify 'changes value' do
        expect {
          instance[:relation_key] = value
        }.to change(instance, :relation_key).to(value)
      end # specify
    end # describe
  end # describe

  describe '#relation_key?' do
    specify { expect(instance).to respond_to(:relation_key?).with(0).arguments }
    specify { expect(instance.relation_key?).to be false }

    describe '#[]' do
      let(:value) { "prefix::suffix" }

      specify 'changes value' do
        expect {
          instance[:relation_key] = value
        }.to change(instance, :relation_key?).to(true)
      end # specify
    end # describe
  end # describe
end # describe
