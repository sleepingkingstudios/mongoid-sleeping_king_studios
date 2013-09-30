# spec/mongoid/sleeping_king_studios/ext/mongoid/document_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

describe Mongoid::Document do
  let(:described_class) do
    Class.new do
      include Mongoid::Document
    end # class
  end # let
  let(:instance) { described_class.new }

  describe '#relations_sleeping_king_studios' do
    specify { expect(described_class).to have_reader :relations_sleeping_king_studios }
    specify { expect(described_class.relations_sleeping_king_studios).to be == Hash.new }
  end # describe
end # describe