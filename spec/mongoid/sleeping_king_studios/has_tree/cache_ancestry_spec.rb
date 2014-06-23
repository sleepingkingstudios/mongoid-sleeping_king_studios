# spec/mongoid/sleeping_king_studios/has_tree/cache_ancestry_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry'

describe Mongoid::SleepingKingStudios::HasTree::CacheAncestry do
  let(:concern) { Mongoid::SleepingKingStudios::HasTree::CacheAncestry }

  shared_examples 'creates the foreign key' do |foreign_key: :ancestor_ids, field_name: :id, **opts|
    describe "#{foreign_key}" do
      specify { expect(instance).to respond_to(foreign_key).with(0).arguments }
      specify { expect(instance.send foreign_key).to be == [instance.send(field_name)] }
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

  shared_examples 'creates the ancestors relation' do |parent_name: :parent, children_name: :children, ancestors_name: :ancestors, foreign_key: :ancestor_ids, field_name: :id|
    let(:factory_name) { described_class.name.split('::').last.underscore.intern }

    describe "#{ancestors_name}" do
      specify { expect(instance).to respond_to(ancestors_name).with(0).arguments }
      specify { expect(instance.send ancestors_name).to be == [] }

      let(:ancestors) do
        ary = []
        3.times do
          ary << FactoryGirl.create(factory_name, parent_name => ary.last)
        end # times
        ary
      end # let
      let(:ancestor_ids) { ancestors.map(&field_name) + [instance.send(metadata.field_name)] }

      describe 'with valid ancestors' do
        before(:each) { instance.send :"#{foreign_key}=", ancestor_ids }

        specify 'returns the ancestors' do
          expect(instance.send ancestors_name).to be == ancestors
        end # specify
      end # describe

      describe 'with unpersisted ancestors' do
        let(:ancestors) do
          super().tap { |ary| ary[1] = FactoryGirl.build factory_name }
        end # let

        before(:each) { instance.send :"#{foreign_key}=", ancestor_ids }

        specify 'raises an error' do
          expect { instance.send ancestors_name }.to raise_error(
            Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError,
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
            Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError,
            /unable to find #{ancestors_name} with ids/
          ) # end expect
        end # specify
      end # describe
    end # describe
  end # shared examples

  shared_examples 'updates the ancestors relation' do |parent_name: :parent, children_name: :children, ancestors_name: :ancestors, foreign_key: :ancestor_ids, field_name: :id|
    let(:factory_name) { described_class.name.split('::').last.underscore.intern }

    describe '#initialize' do
      context 'with a valid parent' do
        let(:parent)   { FactoryGirl.create factory_name }
        let(:instance) { FactoryGirl.build factory_name, parent_name => parent }

        specify 'sets the ancestor ids' do
          expect(instance.send foreign_key).to be == [parent.send(field_name), instance.send(field_name)]
        end # specify

        context 'with many ancestors' do
          let(:ancestors) do
            ary = []
            3.times do
              ary << FactoryGirl.create(factory_name, parent_name => ary.last)
            end # times
            ary
          end # let
          let(:ancestor_ids) { ancestors.map &field_name }
          let(:parent) { FactoryGirl.create factory_name, parent_name => ancestors.last }

          specify 'sets the ancestor ids' do
            expect(instance.send foreign_key).to be == ancestor_ids + [parent.send(field_name), instance.send(field_name)]
          end # specify
        end # context
      end # context
    end # describe

    describe "#{parent_name}=" do
      context 'with a valid parent' do
        let(:parent) { FactoryGirl.create factory_name }

        specify 'sets the parent relation' do
          expect {
            instance.send :"#{parent_name}=", parent
          }.to change(instance, parent_name).to(parent)
        end # specify

        specify 'sets the ancestor ids' do
          expect {
            instance.send :"#{parent_name}=", parent
          }.to change(instance, foreign_key).to([parent.send(field_name), instance.send(field_name)])
        end # specify

        specify 'sets the ancestors' do
          expect {
            instance.send :"#{parent_name}=", parent
          }.to change(instance, ancestors_name).to([parent])
        end # specify

        context 'with many children' do
          let(:children_count) { 3 }
          let(:children) { [*0...children_count].map { FactoryGirl.create factory_name, parent_name => instance } }

          specify 'tests many children' do
            # Can test 1 child at a time while refining specs, but need to test
            # full collection for robust specs.
            expect(children_count).to be > 1
          end # specify

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
            }.to(children.map { |child|
              [ parent.send(field_name),
                instance.send(field_name),
                child.send(field_name)
              ] # end array
            }) # end map, to
          end # specify

          pending 'only locally!'

          context 'with many ancestors' do
            let(:ancestors) do
              ary = []
              3.times do
                ary << FactoryGirl.create(factory_name, parent_name => ary.last)
              end # times
              ary
            end # let
            let(:ancestor_ids) { ancestors.map &field_name }
            let(:parent) { FactoryGirl.create factory_name, parent_name => ancestors.last }

            specify 'updates the children\'s ancestor ids' do
              expect {
                instance.send :"#{parent_name}=", parent
                children.map &:reload
              }.to change {
                children.map &foreign_key
              }.to(children.map { |child|
                ancestor_ids + [
                  parent.send(field_name),
                  instance.send(field_name),
                  child.send(field_name)
                ] # end array
              }) # end map, to
            end # specify

            pending 'only locally!'
          end # context
        end # context

        context 'with many ancestors' do
          let(:ancestors) do
            ary = []
            3.times do
              ary << FactoryGirl.create(factory_name, parent_name => ary.last)
            end # times
            ary
          end # let
          let(:ancestor_ids) { ancestors.map &field_name }
          let(:parent) { FactoryGirl.create factory_name, parent_name => ancestors.last }

          specify 'sets the ancestor ids' do
            expect {
              instance.send :"#{parent_name}=", parent
            }.to change(instance, foreign_key).to(ancestor_ids + [parent.send(field_name), instance.send(field_name)])
          end # specify

          specify 'sets the ancestors' do
            expect {
              instance.send :"#{parent_name}=", parent
            }.to change {
              Set.new(instance.send(ancestors_name))
            }.to(Set.new(ancestors + [parent]))
          end # specify
        end # context
      end # context

      context 'with nil' do
        let(:ancestors) do
          ary = []
          3.times do
            ary << FactoryGirl.create(factory_name, parent_name => ary.last)
          end # times
          ary
        end # let
        let(:parent)   { FactoryGirl.create factory_name, parent_name => ancestors.last }
        let(:instance) { FactoryGirl.build factory_name, parent_name => parent }

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
        let(:parent) { FactoryGirl.create factory_name }

        specify 'sets the parent relation' do
          expect {
            instance.send :"#{parent_name}_id=", parent.id
          }.to change(instance, parent_name).to(parent)
        end # specify

        specify 'sets the ancestor ids' do
          expect {
            instance.send :"#{parent_name}_id=", parent.id
          }.to change(instance, foreign_key).to([parent.send(field_name), instance.send(field_name)])
        end # specify
      end # context
    end # describe

    pending 'id='
  end # shared examples

  shared_examples 'adds the helper methods' do |parent_name: :parent, children_name: :children, ancestors_name: :ancestors, foreign_key: :ancestor_ids, field_name: :id|
    let(:factory_name) { described_class.name.split('::').last.underscore.intern }

    describe '#descendents' do
      specify { expect(instance).to respond_to(:descendents).with(0).arguments }
      specify { expect(instance.descendents).to be_a Mongoid::Criteria }

      let!(:strangers) { [*0..2].map { FactoryGirl.create factory_name } }

      before(:each) { instance.save! }

      specify 'returns an empty array' do
        expect(instance.descendents.to_a).to be == []
      end # specify

      context 'with many children' do
        let!(:children) { [*0..2].map { FactoryGirl.create factory_name, parent_name => instance } }

        specify 'returns the children' do
          expect(instance.descendents.to_a).to be == children
        end # specify

        context 'with many grandchildren' do
          let!(:grandchildren) { children.map { |child| [*0..2].map { FactoryGirl.create factory_name, parent_name => child } }.flatten }

          specify 'returns the children and grandchildren' do
            expect(Set.new instance.descendents).to be == Set.new(children + grandchildren)
          end # specify
        end # context
      end # context

      context 'with many ancestors' do
        let(:ancestors) do
          ary = []
          3.times do
            ary << FactoryGirl.create(factory_name, parent_name => ary.last)
          end # times
          ary
        end # let
        let(:instance) { FactoryGirl.create factory_name, parent_name => ancestors.last }

        specify 'returns an empty array' do
          expect(instance.descendents.to_a).to be == []
        end # specify

        context 'with many children' do
          let!(:children) { [*0..2].map { FactoryGirl.create factory_name, parent_name => instance } }

          specify 'returns the children' do
            expect(Set.new(instance.descendents.to_a)).to be == Set.new(children)
          end # specify

          context 'with many grandchildren' do
            let!(:grandchildren) { children.map { |child| [*0..2].map { FactoryGirl.create factory_name, parent_name => child } }.flatten }

            specify 'returns the children and grandchildren' do
              expect(Set.new instance.descendents).to be == Set.new(children + grandchildren)
            end # specify
          end # context
        end # context
      end # context
    end # describe

    describe '#rebuild_ancestry!' do
      specify { expect(instance).to respond_to(:rebuild_ancestry!).with(0).arguments }

      let(:stranger)    { FactoryGirl.create factory_name }
      let(:grandparent) { FactoryGirl.create factory_name }
      let(:parent)      { FactoryGirl.create factory_name, parent_name => grandparent }

      before(:each) do
        instance.send :"#{parent_name}=", parent
        instance["#{foreign_key}"] = [stranger.send(field_name), nil, parent.send(field_name)]
      end # before each

      specify 'rebuilds the ancestor ids' do
        expect {
          instance.rebuild_ancestry!
        }.to change(instance, foreign_key).to([grandparent.send(field_name), parent.send(field_name)])
      end # specify
    end # describe

    describe '#validate_ancestry' do
      specify { expect(instance).to respond_to(:validate_ancestry).with(0).arguments }

      specify 'does not raise an error' do
        expect { instance.validate_ancestry }.not_to raise_error
      end # specify

      context 'with many ancestors' do
        let(:ancestors) do
          ary = []
          3.times do
            ary << FactoryGirl.create(factory_name, parent_name => ary.last)
          end # times
          ary
        end # let
        let(:instance) { FactoryGirl.build factory_name, parent_name => ancestors.last }

        specify 'does not raise an error' do
          expect { instance.validate_ancestry }.not_to raise_error
        end # specify

        context 'with a missing ancestor' do
          before(:each) { instance[foreign_key][1] = nil }

          specify 'raises an error' do
            expect { instance.validate_ancestry }.to raise_error(
              Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError,
              /unable to find #{ancestors_name} with ids/
            ) # end expectation
          end # specify
        end # context

        context 'with an incorrect ancestor' do
          let(:stranger) { FactoryGirl.create factory_name }
          let(:message) do
            "Problem:\n  Ancestor not found for #{metadata.foreign_key} #{instance[foreign_key]}."
          end

          before(:each) { instance[foreign_key][1] = stranger.send(field_name) }

          specify 'raises an error' do
            # binding.pry
            expect { instance.validate_ancestry }.to raise_error(
              Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError,
              "Problem:\n  Ancestor not found for #{metadata.foreign_key} #{stranger[metadata.foreign_key]}."
            ) # end expectation
          end # specify
        end # context

        context 'with an unexpected ancestor' do
          pending
        end # context
      end # context
    end # describe
  end # shared examples

  shared_examples 'applies concern methods' do
    describe '::build_ancestry_criteria' do
      let(:base)     { described_class }
      let(:values)   { [] }
      let(:criteria) { base.all }

      specify { expect(concern).to respond_to(:build_ancestry_criteria).with(3..4).arguments }

      context 'with an empty array' do
        let(:decorated) { concern.build_ancestry_criteria base, metadata, values }

        specify { expect(decorated).to be_a Mongoid::Criteria }
        specify { expect(decorated.klass).to be base }
        specify { expect(decorated.to_a).to be == [] }
      end # context

      context 'with an empty array and an existing criteria' do
        let(:decorated) { concern.build_ancestry_criteria base, metadata, values, criteria }

        specify { expect(decorated).to be_a Mongoid::Criteria }
        specify { expect(decorated.klass).to be base }
        specify { expect(decorated.to_a).to be == [] }
      end # context

      context 'with many ancestors' do
        let(:ancestors) { [*0..2].map { FactoryGirl.create factory_name } }
        let(:values)    { ancestors.map &metadata.field_name }
        let(:decorated) { concern.build_ancestry_criteria base, metadata, values }
        let(:selector) do
          values.each_with_index.with_object({}) do |(value, index), hsh|
            hsh["#{metadata.foreign_key}.#{index}"] = value
          end # each
        end # let
        let(:instance)  { FactoryGirl.create factory_name }

        before(:each) { instance.update_attribute(metadata.foreign_key, values + [instance.send(metadata.field_name)]) }

        specify { expect(decorated.selector).to be == selector }
        specify { expect(decorated.to_a).to be == [instance] }

        context 'with many children' do
          let(:children) { [*0..2].map { FactoryGirl.create factory_name } }

          before(:each) do
            children.each do |child|
              child.update_attribute(metadata.foreign_key, instance.send(metadata.foreign_key) + [child.send(metadata.field_name)])
            end # each
          end # before each

          specify { expect(decorated.selector).to be == selector }
          specify { expect(Set.new decorated.to_a).to be == Set.new([instance, *children]) }
        end # context
      end # context
    end # describe
  end # shared_examples

  describe '::find_by_ancestry' do
    let(:base)     { Mongoid::SleepingKingStudios::Support::Models::HasTree::NamedAncestors }
    let(:options)  { {} }
    let(:metadata) { Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Metadata.new :name, options }
    let(:values)   { [] }

    specify { expect(concern).to respond_to(:find_by_ancestry).with(3).arguments }
    specify { expect(concern.find_by_ancestry base, metadata, values).to be == [] }
    specify 'calls find with an empty array' do
      expect(base).to receive(:find).with(values).and_return([])
      concern.find_by_ancestry base, metadata, values
    end # specify

    context 'with valid ids' do
      let(:objects) { [*0..2].map { FactoryGirl.create :named_ancestors } }
      let(:values)  { objects.map &:id }

      specify { expect(Set.new(concern.find_by_ancestry base, metadata, values)).to be == Set.new(objects) }
    end # context

    context 'with missing ids' do
      let(:objects) { [*0..2].map { FactoryGirl.create :named_ancestors } }
      let(:values)  { objects.map(&:id).tap { |ary| ary[1] = nil } }
      let(:message) do
        str = "Problem:\n  Ancestor not found for ancestor_ids ["
        str << values.map(&:inspect).join(', ')
        str << '].'
      end

      specify 'raises an error' do
        expect {
          concern.find_by_ancestry base, metadata, values 
        }.to raise_error(
          Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError, message
        ) # end expectation
      end # specify
    end # context
=begin
    context 'with a field name' do
      let(:options) { super().merge :field_name => :name }
      let(:folded)  { [].tap { |ary| values.each_index { |i| ary << values[0..i] } } }

      specify { expect(concern.find_ancestors base, metadata, values).to be == [] }
      specify 'calls where with $in selector' do
        expect(base).to receive(:where).with(metadata.foreign_key => { '$in' => folded }).and_call_original
        concern.find_ancestors base, metadata, values
      end # specify

      context 'with valid names' do
        let(:objects) { [*0..2].map { FactoryGirl.create :named_ancestors } }
        let(:values)  { objects.map(&:name) }

        specify { expect(concern.find_ancestors base, metadata, values).to be == objects }
      end # context

      pending 'with missing names'

      pending 'with duplicate names'
    end # context
=end
  end # describe

  describe '::find_one_by_ancestry' do
    let(:values) { [] }

    specify { expect(concern).to respond_to(:find_one_by_ancestry).with(3).arguments }

    context 'with field_name = id' do
      let(:base)     { Mongoid::SleepingKingStudios::Support::Models::HasTree::Directory }
      let(:options)  { {} }
      let(:metadata) { Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Metadata.new :name, options }

      context 'with an empty array' do
        specify 'raises an error' do
          expect {
            concern.find_one_by_ancestry base, metadata, values
          }.to raise_error(
            Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError,
            "Problem:\n  Ancestor not found for ancestor_ids []."
          ) # end expect
        end # specify
      end # context

      context 'with valid ids' do
        let(:objects) { [*0..2].map { FactoryGirl.create :directory } }
        let(:values)  { objects.map &:id }

        before(:each) do
          objects.last.ancestor_ids = objects.map &:id
          objects.last.save!
        end # before each

        specify 'returns the object' do
          expect(concern.find_one_by_ancestry base, metadata, values).to be == objects.last
        end # specify
      end # specify
    end # context
  end # describe

  describe '::valid_options' do
    specify { expect(concern).to respond_to(:valid_options).with(0).arguments }
    specify { expect(concern.valid_options).to include(:field_name) }
    specify { expect(concern.valid_options).to include(:foreign_key) }
    specify { expect(concern.valid_options).to include(:relation_name) }
  end # describe

  describe '::apply' do
    let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
    let(:described_class) do
      klass = Class.new(namespace::Base) do
        attr_accessor :parent, :children
        attr_writer   :parent_id
      end # class
      klass.send :include, concern
      klass
    end # let
    let(:options)  { {} }
    let(:metadata) { Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Metadata.new :name, options }

    context 'with valid options' do
      specify 'does not raise an error' do
        expect {
          concern.send :apply, described_class, metadata
        }.not_to raise_error
      end # specify
    end # context

    context 'with invalid options' do
      let(:options) { { :defenestrate => true } }

      specify 'raises an error' do
        expect {
          concern.send :apply, described_class, metadata
        }.to raise_error Mongoid::Errors::InvalidOptions
      end # specify
    end # context
  end # describe

  context 'with default options' do
    let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::HasTree::Directory }
    let(:instance)        { described_class.new }
    let(:metadata)        { described_class.relations_sleeping_king_studios['has_tree'][:cache_ancestry] }
    let(:factory_name)    { :directory }

    it_behaves_like 'creates the foreign key'

    it_behaves_like 'creates the ancestors relation'

    it_behaves_like 'updates the ancestors relation'

    it_behaves_like 'adds the helper methods'

    it_behaves_like 'applies concern methods'
  end # context

  context 'with :relation_name => :assemblies' do
    let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::HasTree::Part }
    let(:instance)        { described_class.new }
    let(:metadata)        { described_class.relations_sleeping_king_studios['has_tree'][:cache_ancestry] }
    let(:factory_name)    { :part }

    keywords = {
      :parent_name    => :container,
      :children_name  => :subcomponents,
      :ancestors_name => :assemblies,
      :foreign_key    => :assembly_ids
    } # end hash

    it_behaves_like 'creates the foreign key', **keywords

    it_behaves_like 'creates the ancestors relation', **keywords

    it_behaves_like 'updates the ancestors relation', **keywords

    it_behaves_like 'adds the helper methods', **keywords

    it_behaves_like 'applies concern methods'
  end # context

  context 'with :field_name => :slug' do
    let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::HasTree::Category }
    let(:instance)        { FactoryGirl.build :category }
    let(:metadata)        { described_class.relations_sleeping_king_studios['has_tree'][:cache_ancestry] }
    let(:factory_name)    { :category }

    describe '#slug' do
      specify { expect(instance).to respond_to(:slug).with(0).arguments }
      specify { expect(instance.slug).to be =~ /category-\d+/ }

      describe '=' do
        specify { expect(instance).to respond_to(:slug=).with(1).arguments }

        let(:value) { 'value' }

        specify 'changes the value' do
          expect {
            instance.slug = value
          }.to change(instance, :slug).to value
        end # specify
      end # describe
    end # describe

    keywords = {
      :foreign_key => :ancestor_slugs,
      :field_name  => :slug
    } # end keywords

    it_behaves_like 'creates the foreign key', **keywords

    it_behaves_like 'creates the ancestors relation', **keywords

    it_behaves_like 'updates the ancestors relation', **keywords

    it_behaves_like 'adds the helper methods', **keywords

    pending
  end # context

  pending "NEED TO UPDATE DESCENDENTS ON SAVE ONLY!!!"

  pending "refactor errors to use metadata to structure messages"
end # describe
