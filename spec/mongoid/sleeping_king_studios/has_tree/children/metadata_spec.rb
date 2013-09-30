# spec/mongoid/sleeping_king_studios/has_tree/children/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree/children/metadata'

describe Mongoid::SleepingKingStudios::HasTree::Children::Metadata do
  let(:name)       { :relation }
  let(:properties) { {} }
  let(:instance)   { described_class.new name, properties }

  describe '#inverse_of' do
    specify { expect(instance).to respond_to(:inverse_of).with(0).arguments }
    specify { expect(instance.inverse_of).to be == :parent }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:inverse_of] = value
        }.to change(instance, :inverse_of).to(value)
      end # specify
    end # describe
  end # describe

  describe '#inverse_of?' do
    specify { expect(instance).to respond_to(:inverse_of?).with(0).arguments }
    specify { expect(instance.inverse_of?).to be false }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:inverse_of] = value
        }.to change(instance, :inverse_of?).to(true)
      end # specify
    end # describe
  end # describe

  describe '#relation_name' do
    specify { expect(instance).to respond_to(:relation_name).with(0).arguments }
    specify { expect(instance.relation_name).to be == :children }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:relation_name] = value
        }.to change(instance, :relation_name).to(value)
      end # specify
    end # describe
  end # describe

  describe '#relation_name?' do
    specify { expect(instance).to respond_to(:relation_name?).with(0).arguments }
    specify { expect(instance.relation_name?).to be false }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:relation_name] = value
        }.to change(instance, :relation_name?).to(true)
      end # specify
    end # describe
  end # describe
end # describe
