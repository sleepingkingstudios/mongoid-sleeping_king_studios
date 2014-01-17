# spec/mongoid/sleeping_king_studios/errors/base_error_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/errors/base_error'

RSpec.describe Mongoid::SleepingKingStudios::Errors::BaseError do
  describe 'constructor' do
    specify { expect(described_class).to construct.with(0..1, :details, :summary, :resolution) }
  end # describe

  let(:problem)  { nil }
  let(:keywords) { {} }
  let(:instance) { described_class.new problem, **keywords }

  describe '::DEFAULT_PROBLEM' do
    let(:default_problem) { 'An unknown error occurred.' }

    specify { expect(described_class::DEFAULT_PROBLEM).to be == default_problem }
  end # describe

  describe '#problem' do
    specify { expect(instance).to respond_to(:problem).with(0).arguments }
    specify { expect(instance.problem).to be == described_class::DEFAULT_PROBLEM }

    context 'with a value set' do
      let(:problem) { "You must construct additional Pylons." }

      specify { expect(instance.problem).to be == problem }
    end # context
  end # describe

  describe '#problem=' do
    let(:value) { "You must construct additional Pylons." }

    specify { expect(instance).to respond_to(:problem=).with(1).arguments }
    specify 'changes the value' do
      expect {
        instance.problem = value
      }.to change(instance, :problem).to(value)
    end # specify
  end # describe

  describe '#summary' do
    specify { expect(instance).to respond_to(:summary).with(0).arguments }
    specify { expect(instance.summary).to be nil }

    context 'with a value set' do
      let(:value) { "Pylons provide Supply, which allows you to produce more units." }
      let(:keywords) { super().merge :summary => value }

      specify { expect(instance.summary).to be == value }
    end # context
  end # describe

  describe '#summary=' do
    let(:value) { "Pylons provide Supply, which allows you to produce more units." }

    specify { expect(instance).to respond_to(:summary=).with(1).arguments }
    specify 'changes the value' do
      expect {
        instance.summary = value
      }.to change(instance, :summary).to(value)
    end # specify
  end # describe

  describe '#details' do
    specify { expect(instance).to respond_to(:details).with(0).arguments }
    specify { expect(instance.details).to be nil }

    context 'with a value set' do
      let(:value) { "Each Pylon produces 8 Supply and costs 100 Minerals. Pylons also provide power to nearby structures." }
      let(:keywords) { super().merge :details => value }

      specify { expect(instance.details).to be == value }
    end # context
  end # describe

  describe '#details=' do
    let(:value) { "Each Pylon produces 8 Supply and costs 100 Minerals. Pylons also provide power to nearby structures." }

    specify { expect(instance).to respond_to(:details=).with(1).arguments }
    specify 'changes the value' do
      expect {
        instance.details = value
      }.to change(instance, :details).to(value)
    end # specify
  end # describe

  describe '#resolution' do
    specify { expect(instance).to respond_to(:resolution).with(0).arguments }
    specify { expect(instance.resolution).to be nil }

    context 'with a value set' do
      let(:value) { "Select a probe and click Build to bring up the build menu. Click on the pylon, then on a valid location. The probe will begin warping in the structure." }
      let(:keywords) { super().merge :resolution => value }

      specify { expect(instance.resolution).to be == value }
    end # context
  end # describe

  describe '#resolution=' do
    let(:value) { "Select a probe and click Build to bring up the build menu. Click on the pylon, then on a valid location. The probe will begin warping in the structure." }

    specify { expect(instance).to respond_to(:resolution=).with(1).arguments }
    specify 'changes the value' do
      expect {
        instance.resolution = value
      }.to change(instance, :resolution).to(value)
    end # specify
  end # describe

  describe '#message' do
    let(:default_problem) { described_class::DEFAULT_PROBLEM }

    specify { expect(instance).to respond_to(:message).with(0).arguments }
    specify 'prints the default message' do
      expect(instance.message).to be == "Problem:\n  #{default_problem}"
    end # specify

    context 'with a problem message' do
      let(:problem) { "We require more minerals." }

      specify 'prints the problem message' do
        expect(instance.message).to be == "Problem:\n  #{problem}"
      end # specify
    end # context

    context 'with a summary, details, and resolution' do
      let(:summary)    { "The issue likely originates with your computer's chair-to-keyboard interface." }
      let(:details)    { "The operation failed with an error code of ID 10-T." }
      let(:resolution) { "Have you tried turning it off and on again?" }
      let(:keywords) do
        { :summary => summary,
          :details => details,
          :resolution => resolution
        } # end object
      end # let
      let(:message) do
        str = "Problem:\n  #{default_problem}"
        str += "\nSummary:\n  #{summary}"
        str += "\nDetails:\n  #{details}"
        str += "\nResolution:\n  #{resolution}"
      end # let

      specify 'prints the message with problem, summary, and resolution' do
        expect(instance.message).to be == message
      end # specify
    end # context
  end # describe

  describe 'custom subclass' do
    let(:problem)    { "You must spawn more Overlords." }
    let(:summary)    { "Overlords provide Supply, which allows you to produce more units." }
    let(:details)    { "Each Overlord produces 8 Supply and costs 100 Minerals. Overlords also reveal cloaked units." }
    let(:resolution) { "Select your Hatchery and click Larva, then click the Overlord. A new Overlord will begin to spawn from the selected larva." }
    
    let(:message) do
      str = "Problem:\n  #{problem}"
      str += "\nSummary:\n  #{summary}"
      str += "\nDetails:\n  #{details}"
      str += "\nResolution:\n  #{resolution}"
    end # let

    let(:described_class) do
      klass = Class.new super() do
        def initialize; super(); end
      end # let
      klass.class_eval <<-RUBY
        def problem
          "#{problem}"
        end # method problem

        def summary
          "#{summary}"
        end # method summary

        def details
          "#{details}"
        end # method details

        def resolution
          "#{resolution}"
        end # method resolution
      RUBY
      klass
    end # let
    
    let(:instance) { described_class.new }

    describe '#message' do
      specify { expect(instance.message).to be == message }
    end # describe
  end # describe
end # describe
