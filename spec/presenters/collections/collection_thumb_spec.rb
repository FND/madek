require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'

describe Presenters::Collections::CollectionThumb do
  it 'dummy' do
    # for the rspec updator
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :collection }
  end
end