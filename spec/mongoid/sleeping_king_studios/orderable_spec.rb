# spec/mongoid/sleeping_king_studios/orderable_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/orderable'
require 'mongoid/sleeping_king_studios/orderable/metadata'

RSpec.describe Mongoid::SleepingKingStudios::Orderable do
  let(:concern)      { Mongoid::SleepingKingStudios::Orderable }
  let(:relation_key) { 'orderable' }

  shared_examples 'sets the metadata' do
    let(:loaded_meta)  { described_class.relations_sleeping_king_studios[relation_key] }

    it { expect(loaded_meta).to be_a Mongoid::SleepingKingStudios::Orderable::Metadata }
  end # shared examples

  shared_examples 'defines the field' do |name|
    describe "#{name}" do
      it { expect(instance).to have_reader(name) }
    end # describe

    describe "#{name}=" do
      it { expect(instance).not_to have_writer(name) }
    end # describe
  end # shared examples

  shared_examples 'updates collection on save' do |name|
    let(:loaded_meta)  { described_class.relations_sleeping_king_studios[relation_key] }

    describe '#save' do
      it 'sets the order on the instance' do
        expect {
          instance.save
          instance.reload
        }.to change(instance, loaded_meta.field_name).to(ordered_index)
      end # it

      it 'sets the order on subsequent instances' do
        expect {
          instance.save
          ordered_last.reload
        }.to change(ordered_last, loaded_meta.field_name).to(ordered_count)
      end # it
    end # describe
  end # shared examples

  describe '::valid_options' do
    it { expect(concern).to respond_to(:valid_options).with(0).arguments }
  end # describe

  describe '::cache_ordering' do
    let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
    let(:described_class) do
      klass = Class.new(namespace::Base)
      klass.send :include, concern
      klass
    end # let

    let(:options) { %i() }
    it { expect(described_class).to respond_to(:cache_ordering).with(1, *options) }

    context 'with invalid options' do
      let(:name)    { :jabberwock }
      let(:options) { { :defenestrate => 'snicker-snack' } }

      it 'raises an error' do
        expect {
          described_class.send :cache_ordering, name, options
        }.to raise_error Mongoid::Errors::InvalidOptions
      end # it
    end # context

    context 'with :value and default options' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::Counter }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata'

      it_behaves_like 'defines the field', :value_order

      it_behaves_like 'updates collection on save', :value_order do
        let(:value)         { 9 }
        let(:ordered_index) { 3 }
        let(:ordered_count) { 5 }
        let(:ordered_last)  { described_class.where(:value => 25).first }

        before(:each) do
          [25, 16, 1, 4, 0].each do |value|
            described_class.create! :value => value
          end # each

          instance.send :"#{loaded_meta.attribute}=", value
        end # before each
      end # shared behavior
    end # context
  end # describe
end # describe
