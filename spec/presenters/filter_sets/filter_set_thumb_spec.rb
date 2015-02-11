require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump_spec'

describe Presenters::FilterSets::FilterSetThumb do
  it 'dummy' do
    # for the rspec updator
  end

  it_can_be 'dumped' do
    filter_set = FactoryGirl.create(:filter_set)

    meta_key = \
      (MetaKey.find_by_id('madek:core:title') \
        || FactoryGirl.create(:meta_key_text, id: 'madek:core:title'))

    FactoryGirl.create :meta_datum_text,
                       meta_key: meta_key,
                       filter_set: filter_set

    let(:object) { filter_set }
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :filter_set }
  end
end
