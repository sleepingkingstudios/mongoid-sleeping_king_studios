# spec/mongoid/sleeping_king_studios/tools/criteria_tools_spec.rb

require 'mongoid/sleeping_king_studios/tools/criteria_tools'

RSpec.describe Mongoid::SleepingKingStudios::Tools::CriteriaTools do
  let(:instance) { Object.new.extend described_class }

  describe '#union' do
    shared_examples 'with a literal selector on the source criteria' do
      let(:source) { super().where(:slug => 'slimy') }
    end # shared_examples

    shared_examples 'with a hash selector on the source criteria' do
      let(:source) { super().where(:slug => { '$lte' => 'slimy' }) }
    end # shared_examples

    shared_examples 'with a literal selector on the target criteria' do
      let(:target) { super().where(:slug => 'salt-averse') }
    end # shared_examples

    shared_examples 'with a hash selector on the target criteria' do
      let(:target) { super().where(:slug => { '$gte' => 'salt-averse' }) }
    end # shared_examples

    let(:model)  { Mongoid::SleepingKingStudios::Support::Models::Sluggable::Slug }
    let(:source) { Mongoid::Criteria.new model }
    let(:target) { Mongoid::Criteria.new model }
    let(:result) { described_class.union source, target }

    it { expect(instance).to respond_to(:union).with(2).arguments }

    it { expect(described_class).to respond_to(:union).with(2).arguments }

    it 'returns a Criteria for the specified class' do
      expect(result).to be_a Mongoid::Criteria
      expect(result.klass).to be == model
    end # it

    describe 'with a literal selector on the source criteria' do
      include_context 'with a literal selector on the source criteria'

      it { expect(result.selector).to be == { 'slug' => 'slimy' } }
    end # describe

    describe 'with a hash selector on the source criteria' do
      include_context 'with a hash selector on the source criteria'

      it { expect(result.selector).to be == { 'slug' => { '$lte' => 'slimy' } } }
    end # describe

    describe 'with a literal selector on the target criteria' do
      include_context 'with a literal selector on the target criteria'

      it { expect(result.selector).to be == { 'slug' => 'salt-averse' } }
    end # describe

    describe 'with a hash selector on the target criteria' do
      include_context 'with a hash selector on the target criteria'

      it { expect(result.selector).to be == { 'slug' => { '$gte' => 'salt-averse' } } }
    end # describe

    describe 'with a literal selector on the source and target criteria' do
      include_context 'with a literal selector on the source criteria'
      include_context 'with a literal selector on the target criteria'

      it { expect(result.selector).not_to have_key 'slug' }

      it { expect(result.selector.fetch('$and')).to contain_exactly({ 'slug' => 'slimy' }, { 'slug' => 'salt-averse' }) }
    end # describe

    describe 'with a hash selector on the source and target criteria' do
      include_context 'with a hash selector on the source criteria'
      include_context 'with a hash selector on the target criteria'

      it { expect(result.selector).to be == { 'slug' => { '$lte' => 'slimy', '$gte' => 'salt-averse' } } }
    end # describe
  end # describe
end # describe
