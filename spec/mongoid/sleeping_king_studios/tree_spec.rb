# spec/mongoid/sleeping_king_studios/tree_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/tree'

describe Mongoid::SleepingKingStudios::Tree do
  let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
  before(:each) do
    klass = Class.new namespace::Base
    namespace.const_set :TreeImpl, klass
  end # before each

  after(:each) do
    namespace.send :remove_const, :TreeImpl
  end # after each

  let(:described_class) do
    klass = namespace::TreeImpl
    klass.send :include, super()
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
        expect(described_class.roots.to_a).to be == roots
      end # specify
    end # context
  end # describe

  describe '#parent' do
    specify { expect(instance).to respond_to(:parent).with(0).arguments }
    specify { expect(instance.parent).to be nil }

    context 'with a child' do
      let(:child) { described_class.new }

      specify 'adding a child sets the child\'s parent' do
        instance.children << child
        expect(child.parent).to be == instance
      end # specify
    end # context
  end # describe

  describe '#children' do
    specify { expect(instance).to respond_to(:children).with(0).arguments }
    specify { expect(instance.children).to be == [] }

    context 'with a parent' do
      let(:parent) { described_class.new }

      specify 'setting a parent adds to the parent\'s children' do
        instance.parent = parent
        expect(parent.children).to include instance
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
end # describe
