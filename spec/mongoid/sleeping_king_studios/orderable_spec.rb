# spec/mongoid/sleeping_king_studios/orderable_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/orderable'
require 'mongoid/sleeping_king_studios/orderable/metadata'

RSpec.describe Mongoid::SleepingKingStudios::Orderable do
  let(:concern)      { Mongoid::SleepingKingStudios::Orderable }

  shared_examples 'sets the metadata' do |name|
    let(:loaded_meta)  { described_class.relations_sleeping_king_studios[name.to_s] }

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
    let(:loaded_meta)  { described_class.relations_sleeping_king_studios[name.to_s] }

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

  shared_examples 'creates helpers' do |name|
    let(:base_name)  { name.to_s.gsub(/_order\z/,'') }
    let(:first_name) { "first_#{base_name}".intern }
    let(:last_name)  { "last_#{base_name}".intern }
    let(:next_name)  { "next_#{base_name}".intern }
    let(:prev_name)  { "prev_#{base_name}".intern }

    describe '::first_ordering_name' do
      it { expect(described_class).to respond_to(first_name).with(0..1).arguments }
      it { expect(described_class.send first_name).to be == first_record }

      context 'with a provided scope' do
        let(:scope) { described_class.where(:foo => :bar) }

        it 'filters the result' do
          expect(described_class.send first_name, scope).to be nil
        end # it
      end # context
    end # describe

    describe '::last_ordering_name' do
      it { expect(described_class).to respond_to(last_name).with(0..1).arguments }
      it { expect(described_class.send last_name).to be == last_record }

      context 'with a provided scope' do
        let(:scope) { described_class.where(:foo => :bar) }

        it 'filters the result' do
          expect(described_class.send last_name, scope).to be nil
        end # it
      end # context
    end # describe

    describe '#next_ordering_name' do
      it { expect(instance).to respond_to(next_name).with(0..1).arguments }
      it { expect(instance.send next_name).to be == next_record }

      context 'with a provided scope' do
        let(:scope) { described_class.where(:foo => :bar) }

        it 'filters the result' do
          expect(instance.send next_name, scope).to be nil
        end # it
      end # context
    end # describe

    describe '#prev_ordering_name' do
      it { expect(instance).to respond_to(prev_name).with(0..1).arguments }
      it { expect(instance.send prev_name).to be == prev_record }

      context 'with a provided scope' do
        let(:scope) { described_class.where(:foo => :bar) }

        it 'filters the result' do
          expect(instance.send next_name, scope).to be nil
        end # it
      end # context
    end # describe
  end # shared examples

  describe '::valid_options' do
    it { expect(concern).to respond_to(:valid_options).with(0).arguments }
    it { expect(concern.valid_options).to include :as }
    it { expect(concern.valid_options).to include :filter }
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

      it_behaves_like 'sets the metadata', :value_asc_order do
        before(:each) { $BINDING = true }
        after(:each)  { $BINDING = false }
      end

      it_behaves_like 'defines the field', :value_asc_order

      context 'with created records' do
        let(:value) { 9 }

        before(:each) do
          [25, 16, 1, 4, 0].each do |value|
            described_class.create! :value => value
          end # each

          instance.value = value
        end # before each

        it_behaves_like 'updates collection on save', :value_asc_order do
          let(:ordered_index) { 3 }
          let(:ordered_count) { 5 }
          let(:ordered_last)  { described_class.where(:value => 25).first }
        end # shared behavior

        it_behaves_like 'creates helpers', :value_asc_order do
          let(:first_record) { described_class.where(:value => 0).first }
          let(:last_record)  { described_class.where(:value => 25).first }
          let(:next_record)  { described_class.where(:value => 16).first }
          let(:prev_record)  { described_class.where(:value => 4).first }

          before(:each) { instance.save! }
        end # shared behavior
      end # context
    end # context

    context 'with :value.desc' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::ReverseCounter }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata', :value_desc_order

      it_behaves_like 'defines the field', :value_desc_order

      context 'with created records' do
        let(:value) { 9 }

        before(:each) do
          [25, 16, 1, 4, 0].each do |value|
            described_class.create! :value => value
          end # each

          instance.value = value
        end # before each

        it_behaves_like 'updates collection on save', :value_desc_order do
          let(:ordered_index) { 2 }
          let(:ordered_count) { 5 }
          let(:ordered_last)  { described_class.where(:value => 0).first }
        end # shared behavior

        it_behaves_like 'creates helpers', :value_desc_order do
          let(:first_record) { described_class.where(:value => 25).first }
          let(:last_record)  { described_class.where(:value => 0).first }
          let(:next_record)  { described_class.where(:value => 4).first }
          let(:prev_record)  { described_class.where(:value => 16).first }

          before(:each) { instance.save! }
        end # shared behavior
      end # context
    end # context

    context 'with :letters, :as => :alphabetical_order' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::Word }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata', :alphabetical_order

      it_behaves_like 'defines the field', :alphabetical_order

      context 'with created records' do
        let(:value) { 'bravo' }

        before(:each) do
          ['foxtrot', nil, 'alpha', 'delta', nil, nil, 'charlie', 'echo'].each do |value|
            described_class.create! :letters => value
          end # each

          instance.letters = value
        end # before each

        it_behaves_like 'updates collection on save', :alphabetical_order do
          let(:ordered_index) { 1 }
          let(:ordered_count) { 5 }
          let(:ordered_last)  { described_class.where(:letters => 'foxtrot').first }
        end # shared behavior

        it_behaves_like 'creates helpers', :alphabetical_order do
          let(:first_record) { described_class.where(:letters => 'alpha').first }
          let(:last_record)  { described_class.where(:letters => 'foxtrot').first }
          let(:next_record)  { described_class.where(:letters => 'charlie').first }
          let(:prev_record)  { described_class.where(:letters => 'alpha').first }

          before(:each) { instance.save! }
        end # shared behavior
      end # context
    end # context

    context 'with :primary, :secondary.desc' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::MultiOrder }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata', :primary_asc_secondary_desc_order

      it_behaves_like 'defines the field', :primary_asc_secondary_desc_order

      context 'with created records' do
        let(:primary)   { 0 }
        let(:secondary) { 0 }

        before(:each) do
          [[0,1],[1,0],[1,1],[2,0],[2,1]].each do |(primary, secondary)|
            described_class.create! :primary => primary, :secondary => secondary
          end # each

          instance.primary   = primary
          instance.secondary = secondary
        end # before each

        it_behaves_like 'updates collection on save', :primary_asc_secondary_desc_order do
          let(:ordered_index) { 1 }
          let(:ordered_count) { 5 }
          let(:ordered_last)  { described_class.where(:primary => 2, :secondary => 0).first }
        end # shared behavior

        it_behaves_like 'creates helpers', :primary_asc_secondary_desc_order do
          let(:first_record) { described_class.where(:primary => 0, :secondary => 1).first }
          let(:last_record)  { described_class.where(:primary => 2, :secondary => 0).first }
          let(:next_record)  { described_class.where(:primary => 1, :secondary => 1).first }
          let(:prev_record)  { described_class.where(:primary => 0, :secondary => 1).first }

          before(:each) { instance.save! }
        end # shared behavior
      end # context
    end # context
  end # describe

  describe '::reorder' do
    let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::Word }

    it { expect(described_class).to respond_to(:reorder_alphabetical!).with(0).arguments }

    context 'with a scrambled set' do
      let(:instances) do
        ([nil] + %w(whiskey tango foxtrot) + [nil]).map do |letters|
          described_class.new(:letters => letters).tap &:save
        end # each
      end # let
      let(:whiskey) { instances.select { |word| word.letters == 'whiskey' }.first }
      let(:tango)   { instances.select { |word| word.letters == 'tango'   }.first }
      let(:foxtrot) { instances.select { |word| word.letters == 'foxtrot' }.first }

      before(:each) do
        instances.first.set(:alphabetical_order => 2)
        tango.set(:alphabetical_order => nil)
        foxtrot.set(:alphabetical_order => -1)

        instances.map &:reload
      end # before each

      it 'corrects the order' do
        described_class.reorder_alphabetical!
        instances.map &:reload

        expect(instances.first.alphabetical_order).to be nil
        expect(whiskey.alphabetical_order).to be == 2
        expect(tango.alphabetical_order).to be   == 1
        expect(foxtrot.alphabetical_order).to be == 0
        expect(instances.last.alphabetical_order).to be nil
      end # it
    end # context
  end # describe
end # describe
