require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'

describe Presenters::Collections::CollectionThumb do
  it_responds_to 'privacy_status' do
    let(:resource_type) { :collection }
  end
end
