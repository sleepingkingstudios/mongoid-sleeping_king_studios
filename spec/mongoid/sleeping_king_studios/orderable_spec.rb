# spec/mongoid/sleeping_king_studios/orderable_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/orderable'
require 'mongoid/sleeping_king_studios/orderable/metadata'

RSpec.describe Mongoid::SleepingKingStudios::Orderable do
  let(:concern) { Mongoid::SleepingKingStudios::Orderable }

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

  shared_examples 'updates collection ordering on save' do |ordering_name, examples_name|
    def apply_values instance, fields, values
      fields = [fields].flatten
      values = [values].flatten

      fields.each.with_index { |field, index| instance.send :"#{field}=", values[index] }

      instance.save!
    end # method apply_values

    expect_behavior examples_name

    describe 'when inserting at the beginning of the ordering' do
      before(:each) { apply_values(instance, value_field, first_value) }

      expect_behavior examples_name
    end # describe

    describe 'when inserting in the middle of the ordering' do
      before(:each) { apply_values(instance, value_field, mid_value) }

      expect_behavior examples_name
    end # describe

    describe 'when inserting at the end of the ordering' do
      before(:each) { apply_values(instance, value_field, last_value) }

      expect_behavior examples_name
    end # describe

    describe 'when moving from the middle of the ordering to the beginning' do
      before(:each) do
        apply_values(instance, value_field, mid_value)
        apply_values(instance, value_field, first_value)
      end # before each

      expect_behavior examples_name
    end # describe

    describe 'when moving from the middle of the ordering to the end' do
      before(:each) do
        apply_values(instance, value_field, mid_value)
        apply_values(instance, value_field, last_value)
      end # before each

      expect_behavior examples_name
    end # describe

    describe 'when deleting from the middle of the ordering' do
      before(:each) do
        apply_values(instance, value_field, mid_value)
        instance.destroy
      end # before each

      expect_behavior examples_name
    end # describe
  end # shared_examples

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
    it { expect(concern.valid_options).to include :scope }
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

      expect_behavior 'sets the metadata', :value_asc_order

      expect_behavior 'defines the field', :value_asc_order

      context 'with created records' do
        shared_examples 'orders the documents by value' do
          it 'orders the documents by value' do
            documents = described_class.asc(:value)

            expect(documents.pluck(:value_asc_order)).to be == [*0...documents.count]
          end # it
        end # shared_examples

        let(:value_field) { :value }
        let(:first_value) { -1 }
        let(:mid_value)   { 9 }
        let(:last_value)  { 36 }

        before(:each) do
          [25, 16, 1, 4, 0].each do |value|
            described_class.create! :value => value
          end # each
        end # before each

        expect_behavior 'updates collection ordering on save',
          :value_asc_order,
          'orders the documents by value'

        expect_behavior 'creates helpers', :value_asc_order do
          let(:first_record) { described_class.where(:value => 0).first }
          let(:last_record)  { described_class.where(:value => 25).first }
          let(:next_record)  { described_class.where(:value => 16).first }
          let(:prev_record)  { described_class.where(:value => 4).first }

          before(:each) do
            instance.value = mid_value
            instance.save!
          end # before each
        end # shared behavior
      end # context
    end # context

    context 'with :value.desc' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::ReverseCounter }
      let(:instance)        { described_class.new }

      expect_behavior 'sets the metadata', :value_desc_order

      expect_behavior 'defines the field', :value_desc_order

      context 'with created records' do
        shared_examples 'orders the documents by value' do
          it 'orders the documents by value' do
            documents = described_class.desc(:value)

            expect(documents.pluck(:value_desc_order)).to be == [*0...documents.count]
          end # it
        end # shared_examples

        let(:value_field) { :value }
        let(:first_value) { 36 }
        let(:mid_value)   { 9 }
        let(:last_value)  { -1 }

        before(:each) do
          [25, 16, 1, 4, 0].each do |value|
            described_class.create! :value => value
          end # each
        end # before each

        expect_behavior 'updates collection ordering on save',
          :value_desc_order,
          'orders the documents by value'

        expect_behavior 'creates helpers', :value_desc_order do
          let(:first_record) { described_class.where(:value => 25).first }
          let(:last_record)  { described_class.where(:value => 0).first }
          let(:next_record)  { described_class.where(:value => 4).first }
          let(:prev_record)  { described_class.where(:value => 16).first }

          before(:each) do
            instance.value = mid_value
            instance.save!
          end # before each
        end # shared behavior
      end # context
    end # context

    context 'with :letters, :as => :alphabetical_order' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::Word }
      let(:instance)        { described_class.new }

      expect_behavior 'sets the metadata', :alphabetical_order

      expect_behavior 'defines the field', :alphabetical_order

      context 'with created records' do
        shared_examples 'orders the documents in alphabetical order' do
          it 'orders the documents in alphabetical order' do
            documents = described_class.asc(:letters).where(:letters.ne => nil)

            expect(documents.pluck(:alphabetical_order)).to be == [*0...documents.count]
          end # it
        end # shared_examples

        let(:value_field) { :letters }
        let(:first_value) { 'alpha' }
        let(:mid_value)   { 'bravo' }
        let(:last_value)  { 'foxtrot' }

        before(:each) do
          ['foxtrot', nil, 'alpha', 'delta', nil, nil, 'charlie', 'echo'].each do |value|
            described_class.create! :letters => value
          end # each
        end # before each

        expect_behavior 'updates collection ordering on save',
          :alphabetical_order,
          'orders the documents in alphabetical order'

        expect_behavior 'creates helpers', :alphabetical_order do
          let(:first_record) { described_class.where(:letters => 'alpha').first }
          let(:last_record)  { described_class.where(:letters => 'foxtrot').first }
          let(:next_record)  { described_class.where(:letters => 'charlie').first }
          let(:prev_record)  { described_class.where(:letters => 'alpha').first }

          before(:each) do
            instance.letters = mid_value
            instance.save!
          end # before each
        end # shared behavior
      end # context
    end # context

    context 'with :primary, :secondary.desc' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::MultiOrder }
      let(:instance)        { described_class.new }

      expect_behavior 'sets the metadata', :primary_asc_secondary_desc_order

      expect_behavior 'defines the field', :primary_asc_secondary_desc_order

      context 'with created records' do
        shared_examples 'orders the documents by primary and secondary values' do
          it 'orders the documents by primary and secondary values' do
            documents = described_class.asc(:primary).desc(:secondary)

            expect(documents.pluck(:primary_asc_secondary_desc_order)).to be == [*0...documents.count]
          end # it
        end # shared_examples

        let(:primary)   { 0 }
        let(:secondary) { 0 }

        let(:value_field) { [:primary, :secondary] }
        let(:first_value) { [0, 1] }
        let(:mid_value)   { [0, 0] }
        let(:last_value)  { [2, 0] }

        before(:each) do
          [[0,1],[1,0],[1,1],[2,0],[2,1]].each do |(primary, secondary)|
            described_class.create! :primary => primary, :secondary => secondary
          end # each
        end # before each

        expect_behavior 'updates collection ordering on save',
          :primary_asc_secondary_desc_order,
          'orders the documents by primary and secondary values'

        expect_behavior 'creates helpers', :primary_asc_secondary_desc_order do
          let(:first_record) { described_class.where(:primary => 0, :secondary => 1).first }
          let(:last_record)  { described_class.where(:primary => 2, :secondary => 0).first }
          let(:next_record)  { described_class.where(:primary => 1, :secondary => 1).first }
          let(:prev_record)  { described_class.where(:primary => 0, :secondary => 1).first }

          before(:each) do
            instance.primary   = mid_value[0]
            instance.secondary = mid_value[1]
            instance.save!
          end # before each
        end # shared behavior
      end # context
    end # context

    context 'with :filter => ->() { Hash.new(:a => :hash) }' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::DateOrder }
      let(:instance)        { described_class.new }

      expect_behavior 'sets the metadata', :past_order

      expect_behavior 'defines the field', :past_order

      context 'with created records' do
        shared_examples 'orders the documents by date' do
          it 'orders the documents by date' do
            documents = described_class.asc(:dated_at).where(:dated_at.lte => Time.current)

            expect(documents.pluck(:past_order)).to be == [*0...documents.count]
          end # it
        end # shared_examples

        let(:value_field) { :dated_at }
        let(:first_value) { 5.days.ago.beginning_of_day }
        let(:mid_value)   { 2.days.ago.beginning_of_day }
        let(:last_value)  { 1.days.ago.beginning_of_day }

        before(:each) do
          [-5, -4, -3, -2, -1, 1, 3, 4, 5].each do |value|
            described_class.create! :dated_at => value.days.ago.beginning_of_day
          end # each
        end # before each

        expect_behavior 'updates collection ordering on save',
          :past_order,
          'orders the documents by date'

        expect_behavior 'creates helpers', :past_order do
          let(:first_record) { described_class.where(:dated_at => 5.days.ago.beginning_of_day).first }
          let(:last_record)  { described_class.where(:dated_at => 1.days.ago.beginning_of_day).first }
          let(:next_record)  { described_class.where(:dated_at => 1.days.ago.beginning_of_day).first }
          let(:prev_record)  { described_class.where(:dated_at => 3.days.ago.beginning_of_day).first }

          before(:each) do
            instance.dated_at = mid_value
            instance.save!
          end # before each
        end # shared behavior
      end # context
    end # context

    context 'with :filter => ->() { where(:a => :criteria) }' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::DateOrder }
      let(:instance)        { described_class.new }

      expect_behavior 'sets the metadata', :future_order

      expect_behavior 'defines the field', :future_order

      context 'with created records' do
        shared_examples 'orders the documents by date' do
          it 'orders the documents by date' do
            documents = described_class.asc(:dated_at).where(:dated_at.gte => Time.current)

            expect(documents.pluck(:future_order)).to be == [*0...documents.count]
          end # it
        end # shared_examples

        let(:value_field) { :dated_at }
        let(:first_value) { -1.days.ago.beginning_of_day }
        let(:mid_value)   { -2.days.ago.beginning_of_day }
        let(:last_value)  { -5.days.ago.beginning_of_day }

        before(:each) do
          [-5, -4, -3, -1, 1, 2, 3, 4, 5].each do |value|
            described_class.create! :dated_at => value.days.ago.beginning_of_day
          end # each
        end # before each

        expect_behavior 'updates collection ordering on save',
          :future_order,
          'orders the documents by date'

        expect_behavior 'creates helpers', :future_order do
          let(:first_record) { described_class.where(:dated_at => -1.days.ago.beginning_of_day).first }
          let(:last_record)  { described_class.where(:dated_at => -5.days.ago.beginning_of_day).first }
          let(:next_record)  { described_class.where(:dated_at => -3.days.ago.beginning_of_day).first }
          let(:prev_record)  { described_class.where(:dated_at => -1.days.ago.beginning_of_day).first }

          before(:each) do
            instance.dated_at = mid_value
            instance.save!
          end # before each
        end # shared behavior
      end # context
    end # context

    context 'with :scope => attribute' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Orderable::ScopedOrder }
      let(:instance)        { described_class.new }

      expect_behavior 'sets the metadata', :value_asc_by_category_order

      expect_behavior 'defines the field', :value_asc_by_category_order

      context 'with created records' do
        shared_examples 'orders the documents by value scoped by category' do
          it 'orders the documents by value scoped by category' do
            integer_documents = described_class.where(:category => 'integers').asc(:value)

            expect(integer_documents.pluck(:value_asc_by_category_order)).to be == [*0...integer_documents.count]

            char_documents = described_class.where(:category => 'chars').asc(:value)

            expect(char_documents.pluck(:value_asc_by_category_order)).to be == [*0...char_documents.count]
          end # it
        end # shared_examples

        let(:value_field) { [:value, :category] }
        let(:first_value) { ['a'.ord, 'chars'] }
        let(:mid_value)   { ['d'.ord, 'chars'] }
        let(:last_value)  { ['f'.ord, 'chars'] }

        before(:each) do
          [1, 169, 0, 144, 196, 16, 225, 4, 9, 121].each do |value|
            described_class.create! :category => 'integers', :value => value
          end # each

          ['f', 'e', 'b', 'c', 'a'].each do |value|
            described_class.create! :category => 'chars', :value => value.ord
          end # each
        end # before each

        expect_behavior 'updates collection ordering on save',
          :future_order,
          'orders the documents by value scoped by category' do
            describe 'when changing scoped field' do
              let(:mid_value) { ['d'.ord, 'integers'] }

              describe 'when moving from the middle of the ordering to the beginning' do
                before(:each) do
                  apply_values(instance, value_field, mid_value)
                  apply_values(instance, value_field, first_value)
                end # before each

                expect_behavior 'orders the documents by value scoped by category'
              end # describe

              describe 'when moving from the middle of the ordering to the end' do
                before(:each) do
                  apply_values(instance, value_field, mid_value)
                  apply_values(instance, value_field, last_value)
                end # before each

                expect_behavior 'orders the documents by value scoped by category'
              end # describe
            end # describe
          end # expected behavior

        describe 'creates helpers' do
          shared_examples 'raises an error' do
            let(:error_message) do
              'this ordering is scoped by category -- provide a category value or a criteria filtering results by category'
            end # let

            it 'raises an error' do
              expect { perform_action }.to raise_error ArgumentError, error_message
            end # it
          end # shared_examples

          shared_examples 'requires a scope' do
            describe 'without a scope' do
              let(:arguments) { [] }

              expect_behavior 'raises an error'
            end # describe

            describe 'with a hash without a :category key' do
              let(:scope) { { :foo => :bar  } }

              expect_behavior 'raises an error'
            end # describe

            describe 'with a criteria with no category filter' do
              let(:scope) { described_class.all }

              expect_behavior 'raises an error'
            end # describe

            describe 'with a category value' do
              let(:scope) { 'integers' }

              it 'filters the result' do
                expect(perform_action).to be == expected_value
              end # it
            end # describe

            describe 'with a :category => value hash' do
              let(:scope) { { :category => 'integers' } }

              it 'filters the result' do
                expect(perform_action).to be == expected_value
              end # it
            end # describe

            describe 'with a criteria with a category filter' do
              let(:scope) { described_class.where(:category => 'integers') }

              it 'filters the result' do
                expect(perform_action).to be == expected_value
              end # it
            end # describe
          end # shared_examples

          let(:base_name)  { :value_asc_by_category }
          let(:first_name) { "first_#{base_name}".intern }
          let(:last_name)  { "last_#{base_name}".intern }
          let(:next_name)  { "next_#{base_name}".intern }
          let(:prev_name)  { "prev_#{base_name}".intern }

          before(:each) do
            instance.value    = mid_value[0]
            instance.category = mid_value[1]
            instance.save!
          end # before each

          describe '::first_ordering_name' do
            let(:expected_value) { described_class.where(:category => 'integers', :value => 0).first }
            let(:arguments)      { [scope] }

            it { expect(described_class).to respond_to(first_name).with(0..1).arguments }

            def perform_action
              described_class.send first_name, *arguments
            end # method perform_action

            expect_behavior 'requires a scope'
          end # describe

          describe '::last_ordering_name' do
            let(:expected_value) { described_class.where(:category => 'integers', :value => 225).first }
            let(:arguments)      { [scope] }

            it { expect(described_class).to respond_to(last_name).with(0..1).arguments }

            def perform_action
              described_class.send last_name, *arguments
            end # method perform_action

            expect_behavior 'requires a scope'
          end # describe

          describe '#next_ordering_name' do
            let(:expected_value) { described_class.where(:value => 'e'.ord).first }

            it { expect(instance).to respond_to(next_name).with(0..1).arguments }

            it { expect(instance.send next_name).to be == expected_value }

            context 'with a provided scope' do
              let(:scope) { described_class.where(:foo => :bar) }

              it 'filters the result' do
                expect(instance.send next_name, scope).to be nil
              end # it
            end # context
          end # describe

          describe '#prev_ordering_name' do
            let(:expected_value) { described_class.where(:value => 'c'.ord).first }

            it { expect(instance).to respond_to(prev_name).with(0..1).arguments }

            it { expect(instance.send prev_name).to be == expected_value }

            context 'with a provided scope' do
              let(:scope) { described_class.where(:foo => :bar) }

              it 'filters the result' do
                expect(instance.send prev_name, scope).to be nil
              end # it
            end # context
          end # describe

          describe '::reorder' do
            it { expect(described_class).to respond_to(:reorder_value_asc_by_category!).with(0..1).arguments }

            context 'with scrambled orders' do
              let(:chars)    { described_class.where(:category => 'chars') }
              let(:integers) { described_class.where(:category => 'integers') }

              before(:each) do
                chars.where(:value => 'b'.ord).first.set(:value_asc_by_category_order => 7)
                chars.where(:value => 'e'.ord).first.set(:value_asc_by_category_order => -1)
                chars.where(:value => 'c'.ord).first.set(:value_asc_by_category_order => nil)

                integers.where(:value => 196).first.set(:value_asc_by_category_order => -5)
                integers.where(:value => 16).first.set(:value_asc_by_category_order => 15151)
                integers.where(:value => 121).first.set(:value_asc_by_category_order => nil)
              end # before

              it 'corrects the order of all scopes' do
                described_class.reorder_value_asc_by_category!

                # Corrects the order of char values.
                expect(chars.where(:value => 'b'.ord).first.value_asc_by_category_order).to be == 1

                # Corrects the order of integer values.
                expect(integers.where(:value => 196).first.value_asc_by_category_order).to be == 8
              end # it

              describe 'with a scope' do
                it 'corrects the order of that scope' do
                  described_class.reorder_value_asc_by_category! :chars

                  # Corrects the order of char values.
                  expect(chars.where(:value => 'b'.ord).first.value_asc_by_category_order).to be == 1

                  # Does not corrects the order of integer values.
                  expect(integers.where(:value => 196).first.value_asc_by_category_order).to be == -5
                end # it
              end # describe
            end # context
          end # describe
        end # describe
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
