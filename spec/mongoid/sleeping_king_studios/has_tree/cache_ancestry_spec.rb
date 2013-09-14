# spec/mongoid/sleeping_king_studios/has_tree/cache_ancestry_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry'

describe Mongoid::SleepingKingStudios::HasTree::CacheAncestry do
  let(:concern) { Mongoid::SleepingKingStudios::HasTree::CacheAncestry }

  describe '::cache_ancestry' do
    let(:described_class) do
      klass = Class.new(namespace::Base)
      klass.send :include, concern
      klass
    end # let

    specify { expect(described_class).to respond_to(:cache_ancestry).with(0).arguments }
  end # describe

  describe '::valid_options' do
    specify { expect(concern).to respond_to(:valid_options).with(0).arguments }
    specify { expect(concern.valid_options).to include(:relation_name) }
  end # describe

  let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
  before(:each) do
    klass = Class.new namespace::Base
    namespace.const_set :CacheAncestryImpl, klass
  end # before each

  after(:each) do
    namespace.send :remove_const, :CacheAncestryImpl
  end # after each

  let(:options_cache_ancestry) { true }
  let(:options) { { :cache_ancestry => options_cache_ancestry } }
  let(:described_class) do
    klass = namespace::CacheAncestryImpl
    klass.send :include, Mongoid::SleepingKingStudios::HasTree
    klass.send :has_tree, options
    klass
  end # let
  let(:instance) { described_class.new }

  describe '#ancestor_ids' do
    specify { expect(instance).to respond_to(:ancestor_ids).with(0).arguments }
    specify { expect(instance.ancestor_ids).to be == [] }
  end # describe

  describe '#ancestors_ids=' do
    specify { expect(instance).to respond_to(:ancestor_ids=).with(1).arguments }

    context 'with an array of ids' do
      let(:ancestor_ids) { [*0..2] }

      specify 'sets the ancestor ids' do
        expect {
          instance.ancestor_ids = ancestor_ids
        }.to change {
          instance.ancestor_ids
        }.to(ancestor_ids)
      end # specify
    end # context
  end # describe

  describe '#ancestors' do
    specify { expect(instance).to respond_to(:ancestors).with(0).arguments }
    specify { expect(instance.ancestors).to be == [] }

    let(:ancestors) do
      ary = []
      3.times do
        ary << described_class.create(:parent => ary.last)
      end # times
      ary
    end # let
    let(:ancestor_ids) { ancestors.map &:id }

    describe 'with valid ancestors' do
      before(:each) { instance.ancestor_ids = ancestor_ids }

      specify 'returns the ancestors' do
        expect(instance.ancestors).to be == ancestors
      end # specify
    end # describe

    describe 'with unpersisted ancestors' do
      let(:ancestors) do
        super().tap { |ary| ary[1] = described_class.new }
      end # let

      before(:each) { instance.ancestor_ids = ancestor_ids }

      specify 'raises an error' do
        expect { instance.ancestors }.to raise_error(
          Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor,
          /unable to find ancestors with ids/
        ) # end expect
      end # specify
    end # describe

    describe 'with nil ancestors' do
      let(:ancestor_ids) do
        super().tap { |ary| ary[1] = nil }
      end # let

      before(:each) { instance.ancestor_ids = ancestor_ids }

      specify 'raises an error' do
        expect { instance.ancestors }.to raise_error(
          Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor,
          /unable to find ancestors with ids/
        ) # end expect
      end # specify
    end # describe
  end # describe

  describe '#initialize' do
    context 'with a valid parent' do
      let(:parent) { described_class.create }
      let(:instance) { described_class.new :parent => parent }

      specify 'sets the ancestor ids' do
        expect(instance.ancestor_ids).to be == [parent.id]
      end # specify
    end # context
  end # describe

  describe '#parent=' do
    context 'with a valid parent' do
      let(:parent) { described_class.create }

      specify 'sets the parent relation' do
        expect {
          instance.parent = parent
        }.to change { instance.parent }.to(parent)
      end # specify

      specify 'sets the ancestor ids' do
        expect {
          instance.parent = parent
        }.to change { instance.ancestor_ids }.to([parent.id])
      end # specify

      specify 'sets the ancestors' do
        expect {
          instance.parent = parent
        }.to change { instance.ancestors }.to([parent])
      end # specify

      context 'with many children' do 
        let(:instance) { super().tap &:save! }
        let!(:children) { [*0..0].map { described_class.create! :parent => instance } }

        specify 'updates the children\'s ancestor ids' do
          expect {
            instance.parent = parent
            children.map &:reload
          }.to change {
            children.map &:ancestor_ids
          }.to([*0...children.count].map { [parent.id, instance.id] } )
        end # specify

        context 'with many ancestors' do
          let(:ancestors) do
            ary = []
            3.times do
              ary << described_class.create(:parent => ary.last)
            end # times
            ary
          end # let
          let(:ancestor_ids) { ancestors.map &:id }
          let(:parent) { described_class.create :parent => ancestors.last }

          specify 'updates the children\'s ancestor ids' do
            expect {
              instance.parent = parent
              children.map &:reload
            }.to change {
              children.map &:ancestor_ids
            }.to([*0...children.count].map { ancestor_ids + [parent.id, instance.id] } )
          end # specify
        end # context
      end # context

      context 'with many ancestors' do
        let(:ancestors) do
          ary = []
          3.times do
            ary << described_class.create(:parent => ary.last)
          end # times
          ary
        end # let
        let(:ancestor_ids) { ancestors.map &:id }
        let(:parent) { described_class.create :parent => ancestors.last }

        specify 'sets the ancestor ids' do
          expect {
            instance.parent = parent
          }.to change { instance.ancestor_ids }.to(ancestor_ids + [parent.id])
        end # specify

        specify 'sets the ancestors' do
          expect {
            instance.parent = parent
          }.to change { instance.ancestors }.to(ancestors + [parent])
        end # specify
      end # context
    end # context

    context 'with nil' do
      let(:ancestors) do
        ary = []
        3.times do
          ary << described_class.create(:parent => ary.last)
        end # times
        ary
      end # let
      let(:parent) { described_class.create :parent => ancestors.last }
      let(:instance) { described_class.new :parent => parent }

      specify 'clears the parent relation' do
        expect {
          instance.parent = nil
        }.to change { instance.parent }.to(nil)
      end # specify

      specify 'clears the ancestor ids' do
        expect {
          instance.parent = nil
        }.to change { instance.ancestor_ids }.to([])
      end # specify
    end # context
  end # describe

  describe '#parent_id=' do
    context 'with a valid parent' do
      let(:parent) { described_class.create }

      specify 'sets the parent relation' do
        expect {
          instance.parent_id = parent.id
        }.to change { instance.parent }.to(parent)
      end # specify

      specify 'sets the ancestor ids' do
        expect {
          instance.parent_id = parent.id
        }.to change { instance.ancestor_ids }.to([parent.id])
      end # specify
    end # context
  end # describe

  describe '#descendents' do
    specify { expect(instance).to respond_to(:descendents).with(0).arguments }
    specify { expect(instance.descendents).to be_a Mongoid::Criteria }

    let(:instance) { super().tap &:save! }
    let!(:strangers) { [*0..2].map { described_class.create! } }

    specify 'returns an empty array' do
      expect(instance.descendents.to_a).to be == []
    end # specify

    context 'with many children' do
      let!(:children) { [*0..2].map { described_class.create! :parent => instance } }

      specify 'returns the children' do
        expect(instance.descendents).to be == children
      end # specify

      context 'with many grandchildren' do
        let!(:grandchildren) { children.map { |child| [*0..2].map { described_class.create! :parent => child } }.flatten }

        specify 'returns the children and grandchildren' do
          expect(Set.new instance.descendents).to be == Set.new(children + grandchildren)
        end # specify
      end # context
    end # context

    context 'with many ancestors' do
      let(:ancestors) do
        ary = []
        3.times do
          ary << described_class.create(:parent => ary.last)
        end # times
        ary
      end # let
      let(:instance) { described_class.create! :parent => ancestors.last }

      specify 'returns an empty array' do
        expect(instance.descendents.to_a).to be == []
      end # specify

      context 'with many children' do
        let!(:children) { [*0..2].map { described_class.create! :parent => instance } }

        specify 'returns the children' do
          expect(instance.descendents).to be == children
        end # specify

        context 'with many grandchildren' do
          let!(:grandchildren) { children.map { |child| [*0..2].map { described_class.create! :parent => child } }.flatten }

          specify 'returns the children and grandchildren' do
            expect(Set.new instance.descendents).to be == Set.new(children + grandchildren)
          end # specify
        end # context
      end # context
    end # context
  end # describe

  describe 'rebuild_ancestry!' do
    specify { expect(instance).to respond_to(:rebuild_ancestry!).with(0).arguments }

    let(:stranger)    { described_class.create! }
    let(:grandparent) { described_class.create! }
    let(:parent)      { described_class.create! :parent => grandparent }

    before(:each) do
      instance['parent_id']    = parent.id
      instance['ancestor_ids'] = [stranger.id, nil, parent.id]
    end # before each

    specify 'rebuilds the ancestor ids' do
      expect {
        instance.rebuild_ancestry!
      }.to change {
        instance.ancestor_ids
      }.to([grandparent.id, parent.id])
    end # specify
  end # describe

  describe '#validate_ancestry!' do
    specify { expect(instance).to respond_to(:validate_ancestry!).with(0).arguments }
    specify 'does not raise an error' do
      expect { instance.validate_ancestry! }.not_to raise_error
    end # specify

    context 'with many ancestors' do
      let(:ancestors) do
        ary = []
        3.times do
          ary << described_class.create(:parent => ary.last)
        end # times
        ary
      end # let
      let(:instance) { described_class.new :parent => ancestors.last }

      specify 'does not raise an error' do
        expect { instance.validate_ancestry! }.not_to raise_error
      end # specify

      context 'with a missing ancestor' do
        before(:each) { instance['ancestor_ids'][1] = nil }

        specify 'raises an error' do
          expect { instance.validate_ancestry! }.to raise_error(
            Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor,
            /unable to find ancestor with id/
          ) # end expectation
        end # specify
      end # context

      context 'with an incorrect ancestor' do
        let(:stranger) { described_class.create }

        before(:each) { instance['ancestor_ids'][1] = stranger.id }

        specify 'raises an error' do
          expect { instance.validate_ancestry! }.to raise_error(
            Mongoid::SleepingKingStudios::HasTree::Errors::UnexpectedAncestor,
            /expected ancestor with id/
          ) # end expectation
        end # specify
      end # context
    end # context
  end # describe

  describe '::options[:relation_name]' do
    let(:options_cache_ancestry) { { :relation_name => 'assemblies' } }

    describe '#assembly_ids' do
      specify { expect(instance).to respond_to(:assembly_ids).with(0).arguments }
      specify { expect(instance.assembly_ids).to be == [] }
    end # describe

    describe '#assembly_ids=' do
      specify { expect(instance).to respond_to(:assembly_ids=).with(1).arguments }

      context 'with an array of ids' do
        let(:assembly_ids) { [*0..2] }

        specify 'sets the ancestor ids' do
          expect {
            instance.assembly_ids = assembly_ids
          }.to change {
            instance.assembly_ids
          }.to(assembly_ids)
        end # specify
      end # context
    end # describe

    describe '#assemblies' do
      specify { expect(instance).to respond_to(:assemblies).with(0).arguments }
      specify { expect(instance.assemblies).to be == [] }

      let(:assemblies) do
        ary = []
        3.times do
          ary << described_class.create(:parent => ary.last)
        end # times
        ary
      end # let
      let(:assembly_ids) { assemblies.map &:id }

      describe 'with valid assemblies' do
        before(:each) { instance.assembly_ids = assembly_ids }

        specify 'returns the ancestors' do
          expect(instance.assemblies).to be == assemblies
        end # specify
      end # describe
    end # describe

    describe '#initialize' do
      context 'with a valid parent' do
        let(:parent) { described_class.create }
        let(:instance) { described_class.new :parent => parent }

        specify 'sets the assembly ids' do
          expect(instance.assembly_ids).to be == [parent.id]
        end # specify
      end # context
    end # describe

    describe '#parent=' do
      context 'with a valid parent' do
        let(:parent) { described_class.create }

        specify 'sets the assembly ids' do
          expect {
            instance.parent = parent
          }.to change { instance.assembly_ids }.to([parent.id])
        end # specify

        specify 'sets the assemblies' do
          expect {
            instance.parent = parent
          }.to change { instance.assemblies }.to([parent])
        end # specify
      end # context
    end # describe

    describe '#parent_id=' do
      context 'with a valid parent' do
        let(:parent) { described_class.create }

        specify 'sets the assembly ids' do
          expect {
            instance.parent_id = parent.id
          }.to change { instance.assembly_ids }.to([parent.id])
        end # specify
      end # context
    end # describe

    describe '#descendents' do
      specify { expect(instance).to respond_to(:descendents).with(0).arguments }
      specify { expect(instance.descendents).to be_a Mongoid::Criteria }

      let(:instance) { super().tap &:save! }
      let!(:strangers) { [*0..2].map { described_class.create! } }

      context 'with many assemblies' do
        let(:assemblies) do
          ary = []
          3.times do
            ary << described_class.create(:parent => ary.last)
          end # times
          ary
        end # let
        let(:instance) { described_class.create! :parent => assemblies.last }

        context 'with many children' do
          let!(:children) { [*0..2].map { described_class.create! :parent => instance } }

          specify 'returns the children' do
            expect(instance.descendents).to be == children
          end # specify
        end # context
      end # context
    end # describe

    describe 'rebuild_ancestry!' do
      specify { expect(instance).to respond_to(:rebuild_ancestry!).with(0).arguments }

      let(:stranger)    { described_class.create! }
      let(:grandparent) { described_class.create! }
      let(:parent)      { described_class.create! :parent => grandparent }

      before(:each) do
        instance['parent_id']    = parent.id
        instance['assembly_ids'] = [stranger.id, nil, parent.id]
      end # before each

      specify 'rebuilds the assembly ids' do
        expect {
          instance.rebuild_ancestry!
        }.to change {
          instance.assembly_ids
        }.to([grandparent.id, parent.id])
      end # specify
    end # describe

    describe '#validate_ancestry!' do
      specify { expect(instance).to respond_to(:validate_ancestry!).with(0).arguments }
      specify 'does not raise an error' do
        expect { instance.validate_ancestry! }.not_to raise_error
      end # specify

      context 'with many assemblies' do
        let(:assemblies) do
          ary = []
          3.times do
            ary << described_class.create(:parent => ary.last)
          end # times
          ary
        end # let
        let(:instance) { described_class.new :parent => assemblies.last }

        specify 'does not raise an error' do
          expect { instance.validate_ancestry! }.not_to raise_error
        end # specify

        context 'with a missing assembly' do
          before(:each) { instance['assembly_ids'][1] = nil }

          specify 'raises an error' do
            expect { instance.validate_ancestry! }.to raise_error(
              Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor,
              /unable to find assembly with id/
            ) # end expectation
          end # specify
        end # context

        context 'with an incorrect assembly' do
          let(:stranger) { described_class.create }

          before(:each) { instance['assembly_ids'][1] = stranger.id }

          specify 'raises an error' do
            expect { instance.validate_ancestry! }.to raise_error(
              Mongoid::SleepingKingStudios::HasTree::Errors::UnexpectedAncestor,
              /expected assembly with id/
            ) # end expectation
          end # specify
        end # context
      end # context
    end # describe
  end # describe
end # describe
