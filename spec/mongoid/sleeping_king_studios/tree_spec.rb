# spec/mongoid/sleeping_king_studios/tree_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/tree'

describe Mongoid::SleepingKingStudios::Tree do
  let(:concern) { Mongoid::SleepingKingStudios::Tree }
  describe '::options_for_parent_name' do
    specify { expect(concern).to have_reader(:options_for_parent_name) }
  end # describe

  describe '::options_for_parent_name=' do
    specify { expect(concern).to have_writer(:options_for_parent_name=) }
  end # describe

  describe '::options_for_children_name' do
    specify { expect(concern).to have_reader(:options_for_children_name) }
  end # describe

  describe '::options_for_children_name=' do
    specify { expect(concern).to have_writer(:options_for_children_name=) }
  end # describe

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
    klass.send :include, concern
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

  describe '::options_for_parent' do
    let(:options) { {} }
    let(:options_name) { :options_for_parent }
    let(:described_class) do
      klass = namespace::TreeImpl
      klass.instance_eval <<-RUBY
        def #{options_name}
          #{options}
        end
      RUBY
      klass.send :include, Mongoid::SleepingKingStudios::Tree
      klass
    end # let

    specify { expect(described_class).to respond_to(:options_for_parent).with(0).arguments }
    specify { expect(described_class.options_for_parent).to be == options }

    describe ':relation_name => "overlord"' do
      let(:options) { super().update :relation_name => "overlord" }

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
      let(:options) { super().update :name => "teacher" }

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

    describe 'with a custom options name' do
      let(:options_name) { :customize_parent }

      before(:each) { concern.stub(:options_for_parent_name).and_return(options_name) }

      describe ':relation_name => "manager"' do
        let(:options) { super().update :relation_name => "manager" }

        specify { expect(concern.options_for_parent_name).to be == options_name }

        describe '#manager' do
          specify { expect(instance).to respond_to(:manager).with(0).arguments }
          specify { expect(instance.manager).to be nil }
        end # describe
      end # describe
    end # describe
  end # describe

  describe '::options_for_children' do
    let(:options) { {} }
    let(:options_name) { :options_for_children }
    let(:described_class) do
      klass = namespace::TreeImpl
      klass.instance_eval <<-RUBY
        def #{options_name}
          #{options}
        end
      RUBY
      klass.send :include, Mongoid::SleepingKingStudios::Tree
      klass
    end # let

    specify { expect(described_class).to respond_to(:options_for_children).with(0).arguments }
    specify { expect(described_class.options_for_children).to be == options }

    describe ':relation_name => "minions"' do
      let(:options) { super().update :relation_name => "minions" }

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
      let(:options) { super().update :dependent => :destroy }

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

    describe 'with a custom options name' do
      let(:options_name) { :customize_children }

      before(:each) { concern.stub(:options_for_children_name).and_return(options_name) }

      describe ':relation_name => "employees"' do
        let(:options) { super().update :relation_name => "employees" }

        specify { expect(concern.options_for_children_name).to be == options_name }

        describe '#employees' do
          specify { expect(instance).to respond_to(:employees).with(0).arguments }
          specify { expect(instance.employees).to be == [] }
        end # describe
      end # describe
    end # describe
  end # describe
end # describe
