# spec/mongoid/sleeping_king_studios/has_tree/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree/metadata'

describe Mongoid::SleepingKingStudios::HasTree::Metadata do
  let(:name)       { :has_tree }
  let(:properties) { {} }
  let(:instance)   { described_class.new name, properties }

  describe '#initialize' do
    context 'with parent options' do
      let(:properties) { { :parent => { :key => :value } } }

      describe '#parent' do
        let(:metadata) { instance.parent }

        specify { expect(metadata.name).to be :parent }
        specify { expect(metadata[:key]).to be :value }
      end # describe
    end # context

    context 'with children options' do
      let(:properties) { { :children => { :key => :value } } }

      describe '#parent' do
        let(:metadata) { instance.children }

        specify { expect(metadata.name).to be :children }
        specify { expect(metadata[:key]).to be :value }
      end # describe
    end # context

    context 'with cache_ancestry => true' do
      let(:properties) { { :cache_ancestry => true } }

      describe '#cache_ancestry' do
        let(:metadata) { instance.cache_ancestry }

        specify { expect(metadata).to be_a Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Metadata }
        specify { expect(metadata.children_name).to be :children }
        specify { expect(metadata.parent_name).to   be :parent }
        specify { expect(metadata.name).to be :cache_ancestry }
      end # describe

      context 'with parent and children relation names' do
        let(:children_name) { :subcomponents }
        let(:parent_name)   { :assemblies }
        let(:properties) do
          super().merge :children => { :relation_name => children_name }, :parent => { :relation_name => parent_name }
        end # let
        let(:metadata) { instance.cache_ancestry }

        specify { expect(metadata.children_name).to be children_name }
        specify { expect(metadata.parent_name).to   be parent_name }
      end # context
    end # context

    context 'with cache_ancestry options' do
      let(:relation_name) { :assemblies }
      let(:properties) { { :cache_ancestry => { :key => :value, :relation_name => relation_name } } }

      describe '#cache_ancestry' do
        let(:metadata) { instance.cache_ancestry }
        
        specify { expect(metadata.relation_name).to be == relation_name }
        specify { expect(metadata[:key]).to be :value }
      end # describe
    end # context
  end # describe

  describe '#cache_ancestry' do
    specify { expect(instance).to respond_to(:cache_ancestry).with(0).arguments }
    specify { expect(instance.cache_ancestry).to be nil }

    describe '#[]' do
      let(:value) { :cache_ancestry }

      specify 'changes value' do
        expect {
          instance[:cache_ancestry] = value
        }.to change(instance, :cache_ancestry).to(value)
      end # specify
    end # describe
  end # describe

  describe '#cache_ancestry?' do
    specify { expect(instance).to respond_to(:cache_ancestry?).with(0).arguments }
    specify { expect(instance.cache_ancestry?).to be false }

    describe '#[]' do
      let(:value) { :cache_ancestry }

      specify 'changes value' do
        expect {
          instance[:cache_ancestry] = value
        }.to change(instance, :cache_ancestry?).to(true)
      end # specify
    end # describe
  end # describe

  describe '#children' do
    specify { expect(instance).to respond_to(:children).with(0).arguments }
    specify { expect(instance.children).to be_a Mongoid::SleepingKingStudios::HasTree::Children::Metadata }

    describe '#[]' do
      let(:value) { :children }

      specify 'changes value' do
        expect {
          instance[:children] = value
        }.to change(instance, :children).to(value)
      end # specify
    end # describe
  end # describe

  describe '#foreign_key' do
    specify { expect(instance).to respond_to(:foreign_key).with(0).arguments }
    specify { expect(instance.foreign_key).to be == :parent_id }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance.parent[:relation_name] = value
        }.to change(instance, :foreign_key).to(:"#{value}_id")
      end # specify
    end # describe
  end # describe

  describe '#parent' do
    specify { expect(instance).to respond_to(:parent).with(0).arguments }
    specify { expect(instance.parent).to be_a Mongoid::SleepingKingStudios::HasTree::Parent::Metadata }

    describe '#[]' do
      let(:value) { :parent }

      specify 'changes value' do
        expect {
          instance[:parent] = value
        }.to change(instance, :parent).to(value)
      end # specify
    end # describe
  end # describe
end # describe
