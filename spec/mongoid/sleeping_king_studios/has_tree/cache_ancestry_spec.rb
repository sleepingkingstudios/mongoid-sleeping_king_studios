# spec/mongoid/sleeping_king_studios/has_tree/cache_ancestry_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry'

describe Mongoid::SleepingKingStudios::HasTree::CacheAncestry do
  let(:concern) { Mongoid::SleepingKingStudios::HasTree::CacheAncestry }

  shared_examples 'creates the foreign key' do |parent_name, children_name, ancestors_name, foreign_key, field_name|
    describe "#{foreign_key}" do
      specify { expect(instance).to respond_to(foreign_key).with(0).arguments }
      specify { expect(instance.send foreign_key).to be == [] }
    end # describe

    describe "#{foreign_key}=" do
      specify { expect(instance).to respond_to(:"#{foreign_key}=").with(1).arguments }

      context 'with an array of ids' do
        let(:ancestor_ids) { [*0..2] }

        specify 'sets the ancestor ids' do
          expect {
            instance.send :"#{foreign_key}=", ancestor_ids
          }.to change(instance, foreign_key).to(ancestor_ids)
        end # specify
      end # context
    end # describe
  end # shared examples

  shared_examples 'creates the ancestors relation' do |parent_name, children_name, ancestors_name, foreign_key, field_name|
    describe "#{ancestors_name}" do
      specify { expect(instance).to respond_to(ancestors_name).with(0).arguments }
      specify { expect(instance.send ancestors_name).to be == [] }

      let(:ancestors) do
        ary = []
        3.times do
          ary << described_class.create(parent_name => ary.last)
        end # times
        ary
      end # let
      let(:ancestor_ids) { ancestors.map &:id }

      describe 'with valid ancestors' do
        before(:each) { instance.send :"#{foreign_key}=", ancestor_ids }

        specify 'returns the ancestors' do
          expect(instance.send ancestors_name).to be == ancestors
        end # specify
      end # describe

      describe 'with unpersisted ancestors' do
        let(:ancestors) do
          super().tap { |ary| ary[1] = described_class.new }
        end # let

        before(:each) { instance.send :"#{foreign_key}=", ancestor_ids }

        specify 'raises an error' do
          expect { instance.send ancestors_name }.to raise_error(
            Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor,
            /unable to find #{ancestors_name} with ids/
          ) # end expect
        end # specify
      end # describe

      describe 'with nil ancestors' do
        let(:ancestor_ids) do
          super().tap { |ary| ary[1] = nil }
        end # let

        before(:each) { instance.send :"#{foreign_key}=", ancestor_ids }

        specify 'raises an error' do
          expect { instance.send ancestors_name }.to raise_error(
            Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor,
            /unable to find #{ancestors_name} with ids/
          ) # end expect
        end # specify
      end # describe
    end # describe
  end # shared examples

  shared_examples 'updates the ancestors relation' do |parent_name, children_name, ancestors_name, foreign_key, field_name|
    describe '#initialize' do
      context 'with a valid parent' do
        let(:parent) { described_class.create! }
        let(:instance) { described_class.new parent_name => parent }

        specify 'sets the ancestor ids' do
          expect(instance.send foreign_key).to be == [parent.send(field_name)]
        end # specify

        context 'with many ancestors' do
          let(:ancestors) do
            ary = []
            3.times do
              ary << described_class.create!(parent_name => ary.last)
            end # times
            ary
          end # let
          let(:ancestor_ids) { ancestors.map &field_name }
          let(:parent) { described_class.create! parent_name => ancestors.last }

          specify 'sets the ancestor ids' do
            expect(instance.send foreign_key).to be == ancestor_ids + [parent.send(field_name)]
          end # specify
        end # context
      end # context
    end # describe

    describe "#{parent_name}=" do
      context 'with a valid parent' do
        let(:parent) { described_class.create! }

        specify 'sets the parent relation' do
          expect {
            instance.send :"#{parent_name}=", parent
          }.to change(instance, parent_name).to(parent)
        end # specify

        specify 'sets the ancestor ids' do
          expect {
            instance.send :"#{parent_name}=", parent
          }.to change(instance, foreign_key).to([parent.id])
        end # specify

        specify 'sets the ancestors' do
          expect {
            instance.send :"#{parent_name}=", parent
          }.to change(instance, ancestors_name).to([parent])
        end # specify

        context 'with many children' do
          let(:children) { [*0..0].map { described_class.create! parent_name => instance } }

          before(:each) do
            instance.save!
            children # Create relation after instance is saved.
          end # before each

          specify 'updates the children\'s ancestor ids' do
            expect {
              instance.send :"#{parent_name}=", parent
              children.map &:reload
            }.to change {
              children.map &foreign_key
            }.to([*0...children.count].map { [parent.send(field_name), instance.send(field_name)] } )
          end # specify

          context 'with many ancestors' do
            let(:ancestors) do
              ary = []
              3.times do
                ary << described_class.create!(parent_name => ary.last)
              end # times
              ary
            end # let
            let(:ancestor_ids) { ancestors.map &field_name }
            let(:parent) { described_class.create! parent_name => ancestors.last }

            specify 'updates the children\'s ancestor ids' do
              expect {
                instance.send :"#{parent_name}=", parent
                children.map &:reload
              }.to change {
                children.map &foreign_key
              }.to([*0...children.count].map { ancestor_ids + [parent.send(field_name), instance.send(field_name)] } )
            end # specify
          end # context
        end # context

        context 'with many ancestors' do
          let(:ancestors) do
            ary = []
            3.times do
              ary << described_class.create!(parent_name => ary.last)
            end # times
            ary
          end # let
          let(:ancestor_ids) { ancestors.map &field_name }
          let(:parent) { described_class.create! parent_name => ancestors.last }

          specify 'sets the ancestor ids' do
            expect {
              instance.send :"#{parent_name}=", parent
            }.to change(instance, foreign_key).to(ancestor_ids + [parent.send(field_name)])
          end # specify

          specify 'sets the ancestors' do
            expect {
              instance.send :"#{parent_name}=", parent
            }.to change(instance, ancestors_name).to(ancestors + [parent])
          end # specify
        end # context
      end # context

      context 'with nil' do
        let(:ancestors) do
          ary = []
          3.times do
            ary << described_class.create!(parent_name => ary.last)
          end # times
          ary
        end # let
        let(:parent) { described_class.create! parent_name => ancestors.last }
        let(:instance) { described_class.new parent_name => parent }

        specify 'clears the parent relation' do
          expect {
            instance.send :"#{parent_name}=", nil
          }.to change(instance, parent_name).to(nil)
        end # specify

        specify 'clears the ancestor ids' do
          expect {
            instance.send :"#{parent_name}=", nil
          }.to change(instance, foreign_key).to([])
        end # specify
      end # context
    end # describe

    describe "#{parent_name}_id=" do
      context 'with a valid parent' do
        let(:parent) { described_class.create! }

        specify 'sets the parent relation' do
          expect {
            instance.send :"#{parent_name}_id=", parent.id
          }.to change(instance, parent_name).to(parent)
        end # specify

        specify 'sets the ancestor ids' do
          expect {
            instance.send :"#{parent_name}_id=", parent.id
          }.to change(instance, foreign_key).to([parent.send(field_name)])
        end # specify
      end # context
    end # describe
  end # shared examples

  shared_examples 'adds the helper methods' do |parent_name, children_name, ancestors_name, foreign_key, field_name|
    describe '#descendents' do
      specify { expect(instance).to respond_to(:descendents).with(0).arguments }
      specify { expect(instance.descendents).to be_a Mongoid::Criteria }

      let!(:strangers) { [*0..2].map { described_class.create! } }

      before(:each) { instance.save! }

      specify 'returns an empty array' do
        expect(instance.descendents.to_a).to be == []
      end # specify

      context 'with many children' do
        let!(:children) { [*0..2].map { described_class.create! parent_name => instance } }

        specify 'returns the children' do
          expect(instance.descendents).to be == children
        end # specify

        context 'with many grandchildren' do
          let!(:grandchildren) { children.map { |child| [*0..2].map { described_class.create! parent_name => child } }.flatten }

          specify 'returns the children and grandchildren' do
            expect(Set.new instance.descendents).to be == Set.new(children + grandchildren)
          end # specify
        end # context
      end # context

      context 'with many ancestors' do
        let(:ancestors) do
          ary = []
          3.times do
            ary << described_class.create!(parent_name => ary.last)
          end # times
          ary
        end # let
        let(:instance) { described_class.create! parent_name => ancestors.last }

        specify 'returns an empty array' do
          expect(instance.descendents.to_a).to be == []
        end # specify

        context 'with many children' do
          let!(:children) { [*0..2].map { described_class.create! parent_name => instance } }

          specify 'returns the children' do
            expect(instance.descendents).to be == children
          end # specify

          context 'with many grandchildren' do
            let!(:grandchildren) { children.map { |child| [*0..2].map { described_class.create! parent_name => child } }.flatten }

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
      let(:parent)      { described_class.create! parent_name => grandparent }

      before(:each) do
        instance["#{parent_name}_id"] = parent.send(field_name)
        instance["#{foreign_key}"]    = [stranger.send(field_name), nil, parent.send(field_name)]
      end # before each

      specify 'rebuilds the ancestor ids' do
        expect {
          instance.rebuild_ancestry!
        }.to change {
          instance.send(foreign_key)
        }.to([grandparent.send(field_name), parent.send(field_name)])
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
            ary << described_class.create!(parent_name => ary.last)
          end # times
          ary
        end # let
        let(:instance) { described_class.new parent_name => ancestors.last }

        specify 'does not raise an error' do
          expect { instance.validate_ancestry! }.not_to raise_error
        end # specify

        context 'with a missing ancestor' do
          before(:each) { instance[foreign_key][1] = nil }

          specify 'raises an error' do
            expect { instance.validate_ancestry! }.to raise_error(
              Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor,
              /unable to find #{ancestors_name.to_s.singularize} with id/
            ) # end expectation
          end # specify
        end # context

        context 'with an incorrect ancestor' do
          let(:stranger) { described_class.create }

          before(:each) { instance[foreign_key][1] = stranger.send(field_name) }

          specify 'raises an error' do
            expect { instance.validate_ancestry! }.to raise_error(
              Mongoid::SleepingKingStudios::HasTree::Errors::UnexpectedAncestor,
              /expected #{ancestors_name.to_s.singularize} with id/
            ) # end expectation
          end # specify
        end # context
      end # context
    end # describe
  end # shared examples

  describe '::valid_options' do
    specify { expect(concern).to respond_to(:valid_options).with(0).arguments }
    specify { expect(concern.valid_options).to include(:relation_name) }
  end # describe

  describe '::apply' do
    let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
    let(:described_class) do
      klass = Class.new(namespace::Base)
      klass.send :include, concern
      klass
    end # let

    context 'with valid options' do
      specify 'does not raise an error' do
        expect {
          concern.send :apply, described_class, {}
        }.not_to raise_error
      end # specify
    end # context

    context 'with invalid options' do
      let(:options) { { :defenestrate => true } }

      specify 'raises an error' do
        expect {
          concern.send :apply, described_class, options
        }.to raise_error Mongoid::Errors::InvalidOptions
      end # specify
    end # context
  end # describe

  context 'with default options' do
    let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::HasTree::Directory }
    let(:instance)        { described_class.new }

    params = :parent, :children, :ancestors, :ancestor_ids, :id

    it_behaves_like 'creates the foreign key', *params

    it_behaves_like 'creates the ancestors relation', *params

    it_behaves_like 'updates the ancestors relation', *params

    it_behaves_like 'adds the helper methods', *params
  end # context

  context 'with :relation_name => :assemblies' do
    let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::HasTree::Part }
    let(:instance)        { described_class.new }

    params = :container, :subcomponents, :assemblies, :assembly_ids, :id

    it_behaves_like 'creates the foreign key', *params

    it_behaves_like 'creates the ancestors relation', *params

    it_behaves_like 'updates the ancestors relation', *params

    it_behaves_like 'adds the helper methods', *params
  end # context
end # describe
