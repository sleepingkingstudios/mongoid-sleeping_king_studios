# spec/mongoid/sleeping_king_studios/has_tree_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree'

describe Mongoid::SleepingKingStudios::HasTree do
  let(:concern) { Mongoid::SleepingKingStudios::HasTree }

  shared_examples 'sets the metadata' do |parent_name, children_name|
    let(:relation_key) { 'has_tree' }
    let(:loaded_meta)  { described_class.relations_sleeping_king_studios[relation_key] }

    specify { expect(loaded_meta).to be_a Mongoid::SleepingKingStudios::HasTree::Metadata }

    describe '#parent' do
      let(:loaded_meta) { super().parent }

      describe '#inverse_of' do
        specify { expect(loaded_meta.inverse_of).to be == children_name }
      end # describe

      describe '#relation_name' do
        specify { expect(loaded_meta.relation_name).to be == parent_name }
      end # describe
    end # describe

    describe '#children' do
      let(:loaded_meta) { super().children }

      describe '#inverse_of' do
        specify { expect(loaded_meta.inverse_of).to be == parent_name }
      end # describe

      describe '#relation_name' do
        specify { expect(loaded_meta.relation_name).to be == children_name }
      end # describe
    end # describe
  end # shared examples

  shared_examples 'creates the parent and children relations' do |parent_name, children_name|
    describe "#{parent_name}" do
      specify { expect(instance).to respond_to(parent_name).with(0).arguments }
      specify { expect(instance.send parent_name).to be nil }
    end # describe

    describe "#{children_name}" do
      specify { expect(instance).to respond_to(children_name).with(0).arguments }
      specify { expect(instance.send children_name).to be == [] }
    end # describe

    describe "#{parent_name}=" do
      specify { expect(instance).to respond_to(:"#{parent_name}=").with(1).arguments }

      context 'with a valid parent' do
        let(:parent) { described_class.create! }

        specify 'sets the parent relation' do
          expect {
            instance.send :"#{parent_name}=", parent
          }.to change(instance, parent_name).to(parent)
        end # specify

        specify 'updates the children relation' do
          expect {
            instance.send :"#{parent_name}=", parent
          }.to change { parent.send(children_name).to_a }.to([instance])
        end # specify
      end # context
    end # describe

    describe "#{children_name}<<" do
      specify { expect(instance.send children_name).to respond_to(:<<).with(1).arguments }

      context 'with a valid child' do
        let(:child) { described_class.create! }

        before(:each) { instance.save! }

        specify 'sets the parent relation' do
          expect {
            instance.send(children_name) << child
          }.to change(child, parent_name).to(instance)
        end # specify

        specify 'updates the children relation' do
          expect {
            instance.send(children_name) << child
          }.to change { instance.send(children_name).to_a }.to([child])
        end # specify
      end # context
    end # describe
  end # shared examples

  shared_examples 'adds the helper methods' do |parent_name, children_name|
    describe '::roots' do
      specify { expect(described_class).to respond_to(:roots) }
      specify { expect(described_class.roots).to be_a Mongoid::Criteria }
      specify { expect(described_class.roots.to_a).to be == [] }

      context 'with root objects' do
        let(:roots) do
          [].tap { |ary| 3.times { ary << described_class.create! } }
        end # let

        before(:each) do
          # Create non-root objects to test.
          roots.each do |root|
            rand(1..3).times { described_class.create! :"#{parent_name}_id" => root.id }
          end # each
        end # before each

        specify 'returns the root objects' do
          expect(Set.new described_class.roots.to_a).to be == Set.new(roots)
        end # specify
      end # context
    end # describe

    describe '#root' do
      specify { expect(instance).to respond_to(:root).with(0).arguments }
      specify { expect(instance.root).to be == instance }

      context 'with one ancestor' do
        let(:parent) { described_class.new }

        specify 'returns the parent' do
          instance.send :"#{parent_name}=", parent
          expect(instance.root).to be == parent
        end # specify
      end # context

      context 'with many ancestors' do
        let(:ancestors) do
          [].tap { |ary| 3.times { ary << described_class.new } }
        end # let

        specify 'returns the first ancestor' do
          ancestors[1..-1].each_with_index do |ancestor, index|
            ancestor.send :"#{parent_name}=", ancestors[index - 1]
          end # each with index
          instance.send :"#{parent_name}=", ancestors.last
          expect(instance.root).to be == ancestors.first
        end # specify
      end # context
    end # describe

    describe '#leaf?' do
      specify { expect(instance).to respond_to(:leaf?).with(0).arguments }
      specify { expect(instance).to be_leaf }

      context 'with a child' do
        let(:child) { described_class.new }

        specify 'returns false' do
          instance.send(children_name) << child
          expect(instance).not_to be_leaf
        end # specify
      end # context
    end # describe

    describe '#root?' do
      specify { expect(instance).to respond_to(:root?).with(0).arguments }
      specify { expect(instance).to be_root }

      context 'with a parent' do
        let(:parent) { described_class.new }

        specify 'returns false' do
          instance.send :"#{parent_name}=", parent
          expect(instance).not_to be_root
        end # specify
      end # context
    end # describe
  end # shared examples

  describe '::valid_options' do
    specify { expect(concern).to respond_to(:valid_options).with(0).arguments }
    specify { expect(concern.valid_options).to include(:cache_ancestry) }
    specify { expect(concern.valid_options).to include(:children) }
    specify { expect(concern.valid_options).to include(:parent) }
  end # describe

  describe '::has_tree' do
    let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
    let(:described_class) do
      klass = Class.new(namespace::Base)
      klass.send :include, concern
      klass
    end # let
    let(:valid_options) { %i(parent children) }

    specify { expect(described_class).to respond_to(:has_tree).with(valid_options) }

    context 'with invalid options' do
      let(:options) { { :defenestrate => true } }

      specify 'raises an error' do
        expect {
          described_class.send :has_tree, options
        }.to raise_error Mongoid::Errors::InvalidOptions
      end # specify
    end # context

    context 'with default options' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::HasTree::Tree }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata', :parent, :children

      it_behaves_like 'creates the parent and children relations', :parent, :children

      it_behaves_like 'adds the helper methods', :parent, :children
    end # context

    context 'with :parent => :overlord and :children => :minions' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::HasTree::Villain }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata', :overlord, :minions

      it_behaves_like 'creates the parent and children relations', :overlord, :minions

      it_behaves_like 'adds the helper methods', :overlord, :minions
    end # context
  end # describe
end # describe
