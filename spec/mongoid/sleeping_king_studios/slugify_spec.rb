# spec/mongoid/sleeping_king_studios/slugify_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/slugify'

describe Mongoid::SleepingKingStudios::Slugify do
  let(:model) do
    Class.new do
      include Mongoid::Document
      include Mongoid::SleepingKingStudios::Slugify

      field :name, :type => String
    end # class
  end # let

  let(:instance) { model.new }

  specify { expect(instance).to be_a described_class }

  describe '::slug_base' do
    specify { expect(described_class).to respond_to(:slug_base).with(0).arguments }
  end # describe
end # describe
