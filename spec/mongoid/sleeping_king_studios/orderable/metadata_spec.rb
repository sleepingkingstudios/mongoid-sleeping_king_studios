# subl spec/mongoid/sleeping_king_studios/orderable/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/orderable/metadata'

RSpec.describe Mongoid::SleepingKingStudios::Orderable::Metadata do
  let(:name)       { :orderable }
  let(:attribute)  { :order }
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
end # describe
