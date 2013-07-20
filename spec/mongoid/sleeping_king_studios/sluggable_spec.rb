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
    let(:options) { %i(lockable) }
    specify { expect(described_class).to respond_to(:slugify).with(1, *options) }
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
      specify { expect(instance).not_to have_writer(:slug=) }
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

  context 'with :name and :lockable => true' do
    before(:each) do
      described_class.class_eval do
        field :name, :type => String

        slugify :name, :lockable => true
      end # class eval
    end # before each

    describe '::sluggable_options' do
      let(:options) { { :attribute => :name, :lockable => true } }
      specify { expect(described_class.sluggable_options).to be == options }
    end # describe

    describe '#slug_lock' do
      specify { expect(instance).to have_reader(:slug_lock).with(false) }
    end # describe

    describe '#slug_lock=' do
      specify { expect(instance).to have_writer(:slug_lock=) }
    end # describe

    describe '#slug=' do
      specify { expect(instance).to have_writer(:slug=) }

      specify 'locks the slug' do
        expect { instance.slug = "zeus" }.to change(instance, :slug_lock).from(false).to(true)
      end # specify
    end # describe

    describe 'callbacks' do
      context 'with a name set' do
        before(:each) { instance.name = "Hephaestus" }

        specify 'does not lock the slug' do
          expect { instance.valid? }.not_to change(instance, :slug_lock)
        end # specify
      end # context

      context 'with a name and a slug set' do
        before(:each) do
          instance.name = "Nike"
          instance.slug = "victoria"
        end # before each

        specify 'changes the slug' do
          expect { instance.valid? }.not_to change(instance, :slug)
        end # specify
      end # context
    end # describe

    describe 'validation' do
      context 'with an invalid format' do
        before(:each) { instance.slug = "I'm Not A Valid Slug" }

        specify 'is invalid' do
          expect(instance).to have_errors.on(:slug).
            with_message 'must be lower-case characters a-z, digits 0-9, and hyphens "-"'
        end # specify
      end # context
    end # describe
  end # context
end # describe
