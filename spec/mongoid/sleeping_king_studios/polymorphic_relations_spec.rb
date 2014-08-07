# spec/mongoid/sleeping_king_studios/polymorphic_relations_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/polymorphic_relations'

describe Mongoid::SleepingKingStudios::PolymorphicRelations do
  let(:concern) { Mongoid::SleepingKingStudios::PolymorphicRelations }

  shared_examples 'sets the metadata' do |name|
    let(:loaded_meta)  { described_class.relations_sleeping_king_studios[name.to_s] }

    it { expect(loaded_meta).to be_a Mongoid::SleepingKingStudios::PolymorphicRelations::Metadata }
  end # shared examples

  describe '::valid_options' do
    it { expect(concern).to respond_to(:valid_options).with(0).arguments }
    it { expect(concern.valid_options).to include :class_name }
  end # describe

  describe '::polymorphic_relation' do
    let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
    let(:described_class) do
      klass = Class.new(namespace::Base)
      klass.send :include, concern
      klass
    end # let
    let(:options) { %i(class_name) }

    it { expect(described_class).to respond_to(:polymorphic_relation).with(2, *options) }

    context 'with invalid options' do
      let(:child_relation) { :jabberwock }
      let(:base_relation)  { :mimsy_borogoves }
      let(:options)        { { :vorpal_blade => 'snicker-snack' } }

      specify 'raises an error' do
        expect {
          described_class.send :polymorphic_relation, child_relation, base_relation, **options
        }.to raise_error Mongoid::Errors::InvalidOptions
      end # specify
    end # context

    context 'with :knights, :vassals, and default options' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::PolymorphicRelations::Liege }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata', :polymorphic_relation_vassals_as_knights
    end # context
  end # describe
end # describe
