# spec/mongoid/sleeping_king_studios_spec.rb

require 'mongoid/sleeping_king_studios/spec_helper'

require 'mongoid/sleeping_king_studios'

describe Mongoid::SleepingKingStudios do
  describe '::root' do
    specify { expect(described_class).to respond_to(:root).with(0).arguments }
    specify { expect(described_class.root).to be_a Pathname }

    context 'with a known root directory' do
      let(:root_path) { File.join *%w(foo bar baz) }
      before(:each) do
        allow(described_class).to receive(:__dir__).and_return root_path
      end # before each

      let(:expected_path) do
        File.join root_path, 'sleeping_king_studios'
      end

      specify 'returns the path' do
        expect(described_class.root.to_s).to be == expected_path
      end # specify
    end # context
  end # describe
end # describe
