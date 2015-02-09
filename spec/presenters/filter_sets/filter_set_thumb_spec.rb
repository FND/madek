require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'

describe Presenters::FilterSets::FilterSetThumb do
  it_responds_to 'privacy_status' do
    let(:resource_type) { :filter_set }
  end
end
