# spec/mongoid/sleeping_king_studios/has_tree/cache_ancestry/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/metadata'

describe Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Metadata do
  let(:name)       { :cache_ancestry }
  let(:properties) { {} }
  let(:instance)   { described_class.new name, properties }

  describe '#children_name' do
    specify { expect(instance).to respond_to(:children_name).with(0).arguments }
    specify { expect(instance.children_name).to be == :children }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:children_name] = value
        }.to change(instance, :children_name).to(value)
      end # specify
    end # describe
  end # describe

  describe '#children_name?' do
    specify { expect(instance).to respond_to(:children_name?).with(0).arguments }
    specify { expect(instance.children_name?).to be false }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:children_name] = value
        }.to change(instance, :children_name?).to(true)
      end # specify
    end # describe
  end # describe

  describe '#field_name' do
    specify { expect(instance).to respond_to(:field_name).with(0).arguments }
    specify { expect(instance.field_name).to be == :id }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:field_name] = value
        }.to change(instance, :field_name).to(value)
      end # specify
    end # describe
  end # describe

  describe '#field_name?' do
    specify { expect(instance).to respond_to(:field_name?).with(0).arguments }
    specify { expect(instance.field_name?).to be false }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:field_name] = value
        }.to change(instance, :field_name?).to(true)
      end # specify
    end # describe
  end # describe

  describe '#field_writer' do
    specify { expect(instance).to respond_to(:field_writer).with(0).arguments }
    specify { expect(instance.field_writer).to be == :id= }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:field_name] = value
        }.to change(instance, :field_writer).to(:"#{value}=")
      end # specify
    end # describe
  end # describe

  describe '#foreign_key' do
    specify { expect(instance).to respond_to(:foreign_key).with(0).arguments }
    specify { expect(instance.foreign_key).to be == :ancestor_ids }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:foreign_key] = value
        }.to change(instance, :foreign_key).to(value)
      end # specify
    end # describe

    context 'with a field name set' do
      let(:field_name) { :name }
      let(:properties) { super().merge :field_name => field_name }

      specify 'uses the field name' do
        expect(instance.foreign_key).to be == :"ancestor_#{field_name.to_s.pluralize}"
      end # specify
    end # context

    context 'with a relation name set' do
      let(:relation_name) { :assemblies }
      let(:properties) { super().merge :relation_name => relation_name }

      specify 'uses the relation name' do
        expect(instance.foreign_key).to be == :"#{relation_name.to_s.singularize}_ids"
      end # specify

      describe '#[]' do
        let(:value) { :value }

        specify 'changes value' do
          expect {
            instance[:foreign_key] = value
          }.to change(instance, :foreign_key).to(value)
        end # specify
      end # describe
    end # context
  end # describe

  describe '#foreign_key_writer' do
    specify { expect(instance).to respond_to(:foreign_key_writer).with(0).arguments }
    specify { expect(instance.foreign_key_writer).to be == :ancestor_ids= }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:foreign_key] = value
        }.to change(instance, :foreign_key_writer).to(:"#{value}=")
      end # specify
    end # describe
  end # describe

  describe '#parent_foreign_key' do
    specify { expect(instance).to respond_to(:parent_foreign_key).with(0).arguments }
    specify { expect(instance.parent_foreign_key).to be == :parent_id }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:parent_name] = value
        }.to change(instance, :parent_foreign_key).to(:"#{value}_id")
      end # specify
    end # describe
  end # describe

  describe '#parent_foreign_key_writer' do
    specify { expect(instance).to respond_to(:parent_foreign_key_writer).with(0).arguments }
    specify { expect(instance.parent_foreign_key_writer).to be == :parent_id= }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:parent_name] = value
        }.to change(instance, :parent_foreign_key_writer).to(:"#{value}_id=")
      end # specify
    end # describe
  end # describe

  describe '#parent_name' do
    specify { expect(instance).to respond_to(:parent_name).with(0).arguments }
    specify { expect(instance.parent_name).to be == :parent }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:parent_name] = value
        }.to change(instance, :parent_name).to(value)
      end # specify
    end # describe
  end # describe

  describe '#parent_name?' do
    specify { expect(instance).to respond_to(:parent_name?).with(0).arguments }
    specify { expect(instance.parent_name?).to be false }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:parent_name] = value
        }.to change(instance, :parent_name?).to(true)
      end # specify
    end # describe
  end # describe

  describe '#parent_writer' do
    specify { expect(instance).to respond_to(:parent_writer).with(0).arguments }
    specify { expect(instance.parent_writer).to be == :parent= }

    describe '#[]' do
      let(:value) { :value }

      specify 'changes value' do
        expect {
          instance[:parent_name] = value
        }.to change(instance, :parent_writer).to(:"#{value}=")
      end # specify
    end # describe
  end # describe

  describe '#relation_name' do
    specify { expect(instance).to respond_to(:relation_name).with(0).arguments }
    specify { expect(instance.relation_name).to be == :ancestors }

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