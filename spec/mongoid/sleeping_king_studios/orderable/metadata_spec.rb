# subl spec/mongoid/sleeping_king_studios/orderable/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/orderable/metadata'
require 'mongoid/sleeping_king_studios/support/models/base'

RSpec.describe Mongoid::SleepingKingStudios::Orderable::Metadata do
  let(:name)        { :orderable }
  let(:sort_params) { :placeholder }
  let(:normalized_params) { described_class.normalize_sort_params sort_params }
  let(:properties)  { { :sort_params => normalized_params } }
  let(:instance) do
    described_class.new name, properties
  end # let

  describe '::default_field_name' do
    it { expect(described_class).to respond_to(:default_field_name).with(1).arguments }
    it { expect(described_class.default_field_name normalized_params).to be == :placeholder_asc_order }
  end # describe

  describe '::normalize_sort_params' do
    it { expect(described_class).to respond_to(:normalize_sort_params).with(1).arguments }

    context 'with a symbol' do
      let(:sort_params) { :field_name }

      it 'sets the value' do
        expect(normalized_params).to be == { sort_params => 1 }
      end # it
    end # context

    context 'with a symbol and a direction' do
      let(:sort_params) { :field_name.desc }

      it 'sets the value' do
        expect(normalized_params).to be == { sort_params.name => -1 }
      end # it
    end # context

    context 'with a hash' do
      let(:sort_params) { { :field_name => :desc } }

      it 'sets the value' do
        expect(normalized_params).to be == { sort_params.keys.first => -1 }
      end # it
    end # context

    context 'with an array of symbols' do
      let(:sort_params) { [:first_field, :second_field] }

      it 'sets the value' do
        expect(normalized_params).to be == { sort_params[0] => 1, sort_params[1] => 1 }
      end # it
    end # context

    context 'with a heterogenous array' do
      let(:sort_params) { [:first_field, :second_field.desc] }

      it 'sets the value' do
        expect(normalized_params).to be == { sort_params[0] => 1, sort_params[1].name => -1 }
      end # it
    end # context
  end # describe

  describe '#field_name' do
    it { expect(instance).to respond_to(:field_name).with(0).arguments }
    it { expect(instance.field_name).to be == :placeholder_asc_order }

    describe '#[]' do
      let(:value) { :custom_order }

      it 'changes the value' do
        expect {
          instance[:as] = value
        }.to change(instance, :field_name).to(value)
      end # it
    end # describe

    context 'with :as option' do
      let(:value)      { :chaos }
      let(:properties) { super().merge :as => value }

      it 'returns the value' do
        expect(instance.field_name).to be == value
      end # it
    end # context

    context 'with a String value' do
      let(:value) { 'custom_order' }

      before(:each) { instance[:as] = value }

      it 'returns a Symbol' do
        expect(instance.field_name).to be == value.intern
      end # it
    end # context
  end # describe

  describe '#field_name?' do
    it { expect(instance).to respond_to(:field_name?).with(0).arguments }
    it { expect(instance.field_name?).to be false }

    describe '#[]' do
      let(:value) { :custom_order }

      it 'changes the value' do
        expect {
          instance[:as] = value
        }.to change(instance, :field_name?).to(true)
      end # describe
    end # describe
  end # describe

  describe '#field_was' do
    it { expect(instance).to respond_to(:field_was).with(0).arguments }
    it { expect(instance.field_was).to be == :placeholder_asc_order_was }

    describe '#[]' do
      let(:value) { :custom_order }

      it 'changes the value' do
        expect {
          instance[:as] = value
        }.to change(instance, :field_was).to(:"#{value}_was")
      end # it
    end # describe
  end # describe

  describe '#field_writer' do
    it { expect(instance).to respond_to(:field_writer).with(0).arguments }
    it { expect(instance.field_writer).to be == :placeholder_asc_order= }

    describe '#[]' do
      let(:value) { :custom_order }

      it 'changes the value' do
        expect {
          instance[:as] = value
        }.to change(instance, :field_writer).to(:"#{value}=")
      end # it
    end # describe
  end # describe

  describe '#filter_criteria' do
    let(:base) { Mongoid::SleepingKingStudios::Support::Models::Base }

    it { expect(instance).to respond_to(:filter_criteria).with(1).arguments }
    it { expect(instance.filter_criteria base.all).to be_a Mongoid::Criteria }

    describe 'with filter params' do
      let(:value) { { :value.ne => nil } }

      it 'changes the value' do
        expect {
          instance[:filter] = value
        }.to change {
          instance.filter_criteria(base.all).selector
        }.to({ "value" => { "$ne" => nil } })
      end # it
    end # describe
  end # describe

  describe '#filter_params' do
    it { expect(instance).to respond_to(:filter_params).with(0).arguments }
    it { expect(instance.filter_params).to be nil }

    describe '#[]' do
      let(:value) { { :value.ne => nil } }

      it 'changes the value' do
        expect {
          instance[:filter] = value
        }.to change(instance, :filter_params).to(value)
      end # it
    end # describe
  end # describe

  describe '#filter_params?' do
    it { expect(instance).to respond_to(:filter_params?).with(0).arguments }
    it { expect(instance.filter_params?).to be false }

    describe '#[]' do
      let(:value) { { :value.ne => nil } }

      it 'changes the value' do
        expect {
          instance[:filter] = value
        }.to change(instance, :filter_params?).to(true)
      end # it
    end # describe
  end # describe

  describe '#scope' do
    it { expect(instance).to respond_to(:scope).with(0).arguments }
    it { expect(instance.scope).to be nil }

    describe '#[]' do
      let(:value) { :parent }

      it 'changes the value' do
        expect {
          instance[:scope] = value
        }.to change(instance, :scope).to(value)
      end # it
    end # describe
  end # describe

  describe '#scope?' do
    it { expect(instance).to respond_to(:scope?).with(0).arguments }
    it { expect(instance.scope?).to be false }

    describe '#[]' do
      let(:value) { :parent }

      it 'changes the value' do
        expect {
          instance[:scope] = value
        }.to change(instance, :scope?).to(true)
      end # it
    end # describe
  end # describe

  describe '#sort_criteria' do
    let(:base)         { Mongoid::SleepingKingStudios::Support::Models::Base }
    let(:criteria)     { instance.sort_criteria(base.all) }
    let(:sort_options) { criteria.options[:sort] }

    it { expect(instance).to respond_to(:sort_criteria).with(1).arguments }
    it { expect(instance.sort_criteria base.all).to be_a Mongoid::Criteria }
    it { expect(sort_options).to be == { sort_params.to_s => 1 } }

    describe 'with filter params' do
      let(:value) { { :value.ne => nil } }

      it 'changes the value' do
        expect {
          instance[:filter] = value
        }.to change {
          instance.sort_criteria(base.all).selector
        }.to({ "value" => { "$ne" => nil } })
      end # it
    end # describe
  end # describe
end # describe
