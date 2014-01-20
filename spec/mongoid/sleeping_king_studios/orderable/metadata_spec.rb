# subl spec/mongoid/sleeping_king_studios/orderable/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/orderable/metadata'
require 'mongoid/sleeping_king_studios/support/models/base'

RSpec.describe Mongoid::SleepingKingStudios::Orderable::Metadata do
  let(:name)       { :orderable }
  let(:attribute)  { :value }
  let(:properties) { { :attribute => attribute } }
  let(:instance)   { described_class.new name, properties }

  describe '#attribute' do
    it { expect(instance).to respond_to(:attribute).with(0).arguments }
    it { expect(instance.attribute).to be == attribute }

    describe '#[]' do
      let(:value) { :name }

      it 'changes the value' do
        expect {
          instance[:attribute] = value
        }.to change(instance, :attribute).to(value)
      end # it
    end # describe

    context 'with a String value' do
      let(:attribute)  { 'label' }

      it 'returns a Symbol' do
        expect(instance.attribute).to be == attribute.intern
      end # it
    end # context
  end # describe

  describe '#attribute?' do
    it { expect(instance).to respond_to(:attribute?).with(0).arguments }
    it { expect(instance.attribute?).to be true }

    describe '#[]' do
      let(:value) { nil }

      it 'changes the value' do
        expect {
          instance[:attribute] = value
        }.to change(instance, :attribute?).to(false)
      end # it
    end # describe
  end # describe

  describe '#descending?' do
    it { expect(instance).to respond_to(:descending?).with(0).arguments }
    it { expect(instance.descending?).to be false }

    describe '#[]' do
      let(:value) { true }

      it 'changes the value' do
        expect {
          instance[:descending] = value
        }.to change(instance, :descending?).to(true)
      end # it
    end # describe
  end # describe

  describe '#field_name' do
    it { expect(instance).to respond_to(:field_name).with(0).arguments }
    it { expect(instance.field_name).to be == :"#{attribute}_order" }

    describe '#[]' do
      let(:value) { :custom_order }

      it 'changes the value' do
        expect {
          instance[:field_name] = value
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

      before(:each) { instance[:field_name] = value }

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
          instance[:field_name] = value
        }.to change(instance, :field_name?).to(true)
      end # describe
    end # describe
  end # describe

  describe '#field_writer' do
    it { expect(instance).to respond_to(:field_writer).with(0).arguments }
    it { expect(instance.field_writer).to be == :"#{attribute}_order=" }

    describe '#[]' do
      let(:value) { :custom_order }

      it 'changes the value' do
        expect {
          instance[:field_name] = value
        }.to change(instance, :field_writer).to(:"#{value}=")
      end # it
    end # describe
  end # describe

  describe '#order_nil?' do
    it { expect(instance).to respond_to(:order_nil?).with(0).arguments }
    it { expect(instance.order_nil?).to be false }

    describe '#[]' do
      let(:value) { true }

      it 'changes the value' do
        expect {
          instance[:order_nil?] = value
        }.to change(instance, :order_nil?).to(true)
      end # it
    end # describe
  end # describe

  describe '#sort_criteria' do
    let(:base) { Mongoid::SleepingKingStudios::Support::Models::Base }

    it { expect(instance).to respond_to(:sort_criteria).with(1).arguments }
    it { expect(instance.sort_criteria base).to be_a Mongoid::Criteria }

    describe 'with sort params' do
      let(:value) { :field_name.desc }

      it 'changes the selector' do
        expect {
          instance.sort_params = value
        }.to change {
          instance.sort_criteria(base).options
        }.to(:sort => { "field_name" => -1 })
      end # it
    end # describe
  end # describe

  describe '#sort_params' do
    it { expect(instance).to respond_to(:sort_params).with(0).arguments }
    it { expect(instance.sort_params).to be nil }

    describe '#sort_params=' do
      it { expect(instance).to respond_to(:sort_params=).with(1).arguments }

      context 'with a symbol' do
        let(:value) { :field_name }

        it 'changes the value' do
          expect {
            instance.sort_params = value
          }.to change(instance, :sort_params).to({ value => 1 })
        end # it
      end # context

      context 'with a symbol and a direction' do
        let(:value) { :field_name }

        it 'changes the value' do
          expect {
            instance.sort_params = value.desc
          }.to change(instance, :sort_params).to({ value => -1 })
        end # it
      end # context

      context 'with a hash' do
        let(:value) { { :field_name => :desc } }

        it 'changes the value' do
          expect {
            instance.sort_params = value
          }.to change(instance, :sort_params).to({ value.keys.first => -1 })
        end # it
      end # context

      context 'with an array of symbols' do
        let(:values) { [:first_field, :second_field] }

        it 'changes the value' do
          expect {
            instance.sort_params = values
          }.to change(instance, :sort_params).to({ values[0] => 1, values[1] => 1 })
        end # it
      end # context

      context 'with a heterogenous array' do
        let(:values) { [:first_field, :second_field.desc] }

        it 'changes the value' do
          expect {
            instance.sort_params = values
          }.to change(instance, :sort_params).to({ values[0] => 1, values[1].name => -1 })
        end # it        
      end # context
    end # describe
  end # describe
end # describe
