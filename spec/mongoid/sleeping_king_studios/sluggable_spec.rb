# spec/mongoid/sleeping_king_studios/sluggable_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/sluggable'
require 'mongoid/sleeping_king_studios/sluggable/metadata'

describe Mongoid::SleepingKingStudios::Sluggable do
  let(:concern) { Mongoid::SleepingKingStudios::Sluggable }

  shared_examples 'sets the metadata' do
    let(:relation_key) { 'sluggable' }
    let(:loaded_meta)  { described_class.relations_sleeping_king_studios[relation_key] }

    specify { expect(loaded_meta).to be_a Mongoid::SleepingKingStudios::Sluggable::Metadata }
  end # shared examples

  shared_examples 'defines the field' do |name, writer = true|
    describe "#{name}" do
      specify { expect(instance).to have_reader(name) }
    end # describe

    describe "#{name}=" do
      if writer
        specify { expect(instance).to have_writer(name) }
      else  
        specify { expect(instance).not_to have_writer(name) }
      end # if-else
    end # describe
  end # shared examples

  shared_examples 'redefines the accessor' do |source, target, value = 'Sample String'|
    let(:relation_key) { 'sluggable' }
    let(:loaded_meta)  { described_class.relations_sleeping_king_studios[relation_key] }

    describe "#{source}=" do
      specify "changes #{target}" do
        expect {
          instance.send :"#{source}=", value
        }.to change(instance, target).to loaded_meta.value_to_slug(value)
      end # specify
    end # describe
  end # shared examples

  shared_examples 'validates the field' do |name|
    context "with an empty #{name}" do
      specify 'is invalid' do
        expect(instance).to have_errors.on(name).with_message(/can't be blank/)
      end # specify
    end # context

    context "with a non-empty #{name}" do
      before(:each) { instance['slug'] = "sample-slug" }

      specify 'is valid' do
        expect(instance).not_to have_errors
      end # specify
    end # context
  end # shared_examples

  shared_examples 'defines the helpers' do |source, target, lockable = false|
    describe '::slugify_all!' do
      it { expect(described_class).to respond_to(:slugify_all!).with(0).arguments }

      context 'with created objects' do
        let!(:objects) do
          objects = [*0..3].map { |index| described_class.create! source => "Object #{index}" }
          objects[0].set :slug => nil
          objects[1].set :slug => ''
          objects[2].set :slug => 'random-slug'

          if lockable
            objects[-1] = described_class.create! source => "Object 3"
            objects[-1].set :slug => 'locked-slug'
            objects[-1].set :slug_lock, true
          end # if

          objects.map &:reload
        end # let

        context 'with a nil slug' do
          let(:instance) { objects[0] }
          
          it 'replaces with the processed base field' do
            expect {
              described_class.slugify_all!
              instance.reload
            }.to change(instance, :slug).to(instance.send(source).parameterize)
          end # it
        end # context

        context 'with an empty slug' do
          let(:instance) { objects[1] }
          
          it 'replaces with the processed base field' do
            expect {
              described_class.slugify_all!
              instance.reload
            }.to change(instance, :slug).to(instance.send(source).parameterize)
          end # it
        end # context

        context 'with a mismatched slug' do
          let(:instance) { objects[2] }
          
          it 'replaces with the processed base field' do
            expect {
              described_class.slugify_all!
              instance.reload
            }.to change(instance, :slug).to(instance.send(source).parameterize)
          end # it
        end # context

        context 'with a matching slug' do
          let(:instance) { objects[3] }

          it 'does not change' do
            expect {
              described_class.slugify_all!
              instance.reload
            }.not_to change(instance, :slug)
          end # it
        end # context

        if lockable
          context 'with a locked slug' do
            let(:instance) { objects[-1] }

            it 'does not change' do
              expect {
                described_class.slugify_all!
                instance.reload
              }.not_to change(instance, :slug)
            end # it
          end # context
        end # if
      end # context
    end # describe
  end # shared examples

  describe '::valid_options' do
    specify { expect(concern).to respond_to(:valid_options).with(0).arguments }
    specify { expect(concern.valid_options).to include :lockable }
  end # describe

  describe '::slugify' do
    let(:namespace) { Mongoid::SleepingKingStudios::Support::Models }
    let(:described_class) do
      klass = Class.new(namespace::Base)
      klass.send :include, concern
      klass
    end # let

    let(:options) { %i(lockable) }
    specify { expect(described_class).to respond_to(:slugify).with(1, *options) }

    context 'with invalid options' do
      let(:name)    { :jabberwock }
      let(:options) { { :defenestrate => 'snicker-snack' } }

      specify 'raises an error' do
        expect {
          described_class.send :slugify, name, options
        }.to raise_error Mongoid::Errors::InvalidOptions
      end # specify
    end # context

    context 'with :name and default options' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Sluggable::Slug }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata'

      it_behaves_like 'defines the field', :slug, false

      it_behaves_like 'redefines the accessor', :name, :slug

      it_behaves_like 'validates the field', :slug

      it_behaves_like 'defines the helpers', :name, :slug

      context 'saved' do
        before(:each) do
          instance['slug'] = 'pygmalion'
          instance.save!
        end # before each

        specify 'does not raise an error on reload' do
          expect { instance.reload }.not_to raise_error
        end # specify
      end # context
    end # context

    context 'with :name and :lockable => true' do
      let(:described_class) { Mongoid::SleepingKingStudios::Support::Models::Sluggable::Lock }
      let(:instance)        { described_class.new }

      it_behaves_like 'sets the metadata'

      it_behaves_like 'defines the field', :slug, true

      it_behaves_like 'defines the field', :slug_lock, true

      it_behaves_like 'redefines the accessor', :name, :slug

      it_behaves_like 'validates the field', :slug

      it_behaves_like 'defines the helpers', :name, :slug

      describe '#slug=' do
        specify 'locks the slug' do
          expect {
            instance.slug = "zeus"
          }.to change(instance, :slug_lock).from(false).to(true)
        end # specify
      end # describe

      context 'locked' do
        before(:each) do
          instance['slug'] = 'prolegomenon'
          instance['slug_lock'] = true
        end # before each

        let(:value) { "Something Classy" }

        describe 'name=' do
          specify 'does not change the slug' do
            expect {
              instance.name = value
            }.not_to change(instance, :slug)
          end # specify
        end # describe

        context 'and unlocked' do
          before(:each) { instance['slug_lock'] = false }

          describe 'name=' do
            specify 'changes the slug' do
              expect {
                instance.name = value
              }.to change(instance, :slug)
            end # specify
          end # describe
        end # context
      end # context
    end # context  
  end # describe
end # describe
