# spec/mongoid/sleeping_king_studios/sluggable_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/sluggable'

describe Mongoid::SleepingKingStudios::Sluggable do
  let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
  before(:each) do
    klass = Class.new namespace::Base
    namespace.const_set :SluggableImpl, klass
  end # before each

  after(:each) do
    namespace.send :remove_const, :SluggableImpl
  end # after each

  let(:described_class) do
    klass = namespace::SluggableImpl
    klass.send :include, super()
    klass
  end # let
  let(:instance) { described_class.new }

  describe '::slugify' do
    specify { expect(described_class).to respond_to(:slugify).with(1) }
  end # describe

  describe '::sluggable_options' do
    specify { expect(described_class).to have_reader(:sluggable_options) }
  end # describe

  context 'with :name and default options' do
    before(:each) do
      described_class.class_eval do
        field :name, :type => String

        slugify :name
      end # class eval
    end # before each

    describe '::sluggable_options' do
      specify { expect(described_class.sluggable_options).to be == { :attribute => :name } }
    end # describe

    describe '#slug' do
      specify { expect(instance).to have_reader(:slug) }
    end # describe

    describe '#slug=' do
      specify { expect(instance).to have_writer(:slug=) }
    end # describe

    describe 'to_slug' do
      specify { expect(instance).to have_reader(:to_slug).with("") }

      describe 'converts to dashed snake case' do
        before(:each) { instance.name = "Galactic Ley Line" }

        specify { expect(instance.to_slug).to be == "galactic-ley-line" }
      end # describe

      describe 'processes non-URL characters' do
        before(:each) { instance.name = "Zweihänder" }

        specify { expect(instance.to_slug).to be == "zweihander" }
      end # describe

      describe 'removes single and double quotes' do
        before(:each) { instance.name = "Hello, my name's \"Macintosh\"." }

        specify { expect(instance.to_slug).to be == "hello-my-names-macintosh" }
      end # describe
    end # describe

    describe 'callbacks' do
      specify 'evaluates slug before validation' do
        expect(instance).to receive(:to_slug)
        instance.valid?
      end # specify

      context 'with a name set' do
        before(:each) { instance.name = "Athena" }

        specify 'changes the slug' do
          expect { instance.valid? }.to change(instance, :slug).from(nil).to("athena")
        end # specify
      end # context
    end # describe

    describe 'validation' do
      context 'with an empty slug' do
        specify 'is invalid' do
          expect(instance).to have_errors.on(:slug).with_message(/can't be blank/)
        end # specify
      end # context

      context 'with a non-empty slug' do
        before(:each) { instance.name = "Amare Et Sapere Vix Deo Conceditur" }

        specify 'is valid' do
          expect(instance).not_to have_errors
        end # specify
      end # context
    end # describe
  end # context
end # describe
