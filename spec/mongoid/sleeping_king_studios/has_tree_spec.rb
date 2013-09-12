# spec/mongoid/sleeping_king_studios/tree_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree'

describe Mongoid::SleepingKingStudios::HasTree do
  let(:concern) { Mongoid::SleepingKingStudios::HasTree }

  describe '::valid_options' do
    specify { expect(concern).to respond_to(:valid_options).with(0).arguments }
    specify { expect(concern.valid_options).to include(:cache_ancestry) }
    specify { expect(concern.valid_options).to include(:children) }
    specify { expect(concern.valid_options).to include(:parent) }
  end # describe

  describe '::has_tree' do
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
  end # describe

  let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
  before(:each) do
    klass = Class.new namespace::Base
    namespace.const_set :HasTreeImpl, klass
  end # before each

  after(:each) do
    namespace.send :remove_const, :HasTreeImpl
  end # after each

  let(:options_for_parent)   { {} }
  let(:options_for_children) { {} }
  let(:options) { { :parent => options_for_parent, :children => options_for_children } }
  let(:described_class) do
    klass = namespace::HasTreeImpl
    klass.send :include, concern
    klass.send :has_tree, options
    klass
  end # let
  let(:instance) { described_class.new }

  describe '::roots' do
    specify { expect(described_class).to respond_to(:roots) }
    specify { expect(described_class.roots).to be_a Mongoid::Criteria }
    specify { expect(described_class.roots.to_a).to be == [] }

    context 'with root objects' do
      let(:roots) do
        [].tap { |ary| 3.times { ary << described_class.new } }
      end # let

      specify 'returns the root objects' do
        roots.each do |root|
          root.save!
          rand(1..3).times { described_class.create! :parent_id => root.id }
        end # each
        expect(Set.new described_class.roots.to_a).to be == Set.new(roots)
      end # specify
    end # context
  end # describe

  describe '#parent' do
    specify { expect(instance).to respond_to(:parent).with(0).arguments }
    specify { expect(instance.parent).to be nil }
  end # describe

  describe '#children' do
    specify { expect(instance).to respond_to(:children).with(0).arguments }
    specify { expect(instance.children).to be == [] }
  end # describe

  describe '#parent=' do
    specify { expect(instance).to respond_to(:parent=).with(1).arguments }

    context 'with a valid parent' do
      let(:parent) { described_class.create }

      specify 'sets the parent relation' do
        expect {
          instance.parent = parent
        }.to change { instance.parent }.to(parent)
      end # specify

      specify 'updates the children relation' do
        expect {
          instance.parent = parent
        }.to change { parent.children.to_a }.to([instance])
      end # specify
    end # context
  end # describe

  describe '#children<<' do
    specify { expect(instance.children).to respond_to(:<<).with(1).arguments }

    context 'with a valid child' do
      let(:child) { described_class.create }

      before(:each) { instance.save }

      specify 'sets the parent relation' do
        expect {
          instance.children << child
        }.to change(child, :parent).to(instance)
      end # specify

      specify 'updates the children relation' do
        expect {
          instance.children << child
        }.to change { instance.children.to_a }.to([child])
      end # specify
    end # context
  end # describe

  describe '#root' do
    specify { expect(instance).to respond_to(:root).with(0).arguments }
    specify { expect(instance.root).to be == instance }

    context 'with one ancestor' do
      let(:parent) { described_class.new }

      specify 'returns the parent' do
        instance.parent = parent
        expect(instance.root).to be == parent
      end # specify
    end # context

    context 'with many ancestors' do
      let(:ancestors) do
        [].tap { |ary| 3.times { ary << described_class.new } }
      end # let

      specify 'returns the first ancestor' do
        ancestors[1..-1].each_with_index do |ancestor, index|
          ancestor.parent = ancestors[index - 1]
        end # each with index
        instance.parent = ancestors.last
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
        instance.children << child
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
        instance.parent = parent
        expect(instance).not_to be_root
      end # specify
    end # context
  end # describe

  describe '::options[:parent]' do
    describe ':relation_name => "overlord"' do
      let(:options_for_parent) { super().update :relation_name => "overlord" }

      describe '#overlord' do
        specify { expect(instance).to respond_to(:overlord).with(0).arguments }
        specify { expect(instance.overlord).to be nil }
      end # describe

      describe '#overlord=' do
        specify { expect(instance).to respond_to(:overlord=).with(1).arguments }

        context 'with a valid parent' do
          let(:parent) { described_class.create }

          specify 'sets the parent relation' do
            expect {
              instance.overlord = parent
            }.to change { instance.overlord }.to(parent)
          end # specify

          specify 'updates the children relation' do
            expect {
              instance.overlord = parent
            }.to change { parent.children.to_a }.to([instance])
          end # specify
        end # context
      end # describe
    end # describe

    describe ':name => "teacher"' do
      let(:options_for_parent) { super().update :name => "teacher" }

      specify { expect(instance).to respond_to(:teacher_id).with(0).arguments }
      specify { expect(instance.teacher_id).to be nil }

      describe '#parent=' do
        let(:parent) { described_class.new }

        specify 'changes the teacher id' do
          expect {
            instance.parent = parent
          }.to change { instance.teacher_id }.to parent.id
        end # specify
      end # describe
    end # describe
  end # describe

  describe '::options[:children]' do
    describe ':relation_name => "minions"' do
      let(:options_for_children) { super().update :relation_name => "minions" }

      describe '#minions' do
        specify { expect(instance).to respond_to(:minions).with(0).arguments }
        specify { expect(instance.minions).to be == [] }
      end # describe

      describe '#minions<<' do
        specify { expect(instance.minions).to respond_to(:<<).with(1).arguments }

        context 'with a valid child' do
          let(:child) { described_class.create }

          before(:each) { instance.save }

          specify 'sets the parent relation' do
            expect {
              instance.minions << child
            }.to change(child, :parent).to(instance)
          end # specify

          specify 'updates the children relation' do
            expect {
              instance.minions << child
            }.to change { instance.minions.to_a }.to([child])
          end # specify
        end # context
      end # describe
    end # describe

    describe ':dependent => :destroy' do
      let(:options_for_children) { super().update :dependent => :destroy }

      context 'with a child' do
        let!(:child) { described_class.create :parent => instance }

        before(:each) { instance.save }

        specify 'destroys the child' do
          expect {
            instance.destroy
          }.to change { described_class.count }.from(2).to(0)
        end # specify
      end # context
    end # describe
  end # describe
end # describe
