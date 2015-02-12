require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump_spec'

describe Presenters::MediaEntries::MediaEntryThumb do
  it 'dummy' do
    # for the rspec updator
  end

  it_can_be 'dumped' do
    media_entry = FactoryGirl.create(:media_entry)

    meta_key = MetaKey.find_by_id('madek:core:title')

    # protect against strange bug/missing core meta_key
    throw 'core:title should be in db!!!' unless meta_key

    FactoryGirl.create :meta_datum_text,
                       meta_key: meta_key,
                       media_entry: media_entry

    let(:object) { media_entry }
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :media_entry }
  end
end
