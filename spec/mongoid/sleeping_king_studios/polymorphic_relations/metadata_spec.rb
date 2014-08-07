# spec/mongoid/sleeping_king_studios/polymorphic_relations/metadata_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios/polymorphic_relations/metadata'

describe Mongoid::SleepingKingStudios::PolymorphicRelations::Metadata do
  let(:child_relation) { :trees }
  let(:base_relation)  { :plants }

  describe '::default_field_name' do
    let(:relation_name) { :"polymorphic_relation_#{base_relation}_as_#{child_relation}" }

    it { expect(described_class).to respond_to(:default_field_name).with(2).arguments }
    it { expect(described_class.default_field_name child_relation, base_relation).to be == relation_name }
  end # describe
end # describe
