require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump_spec'

describe Presenters::Collections::CollectionThumb do
  it 'dummy' do
    # for the rspec updator
  end

  it_can_be 'dumped' do
    collection = FactoryGirl.create(:collection)

    meta_key = \
      MetaKey.find_by_id('madek:core:title') \
        or with_disabled_triggers do
          # TODO: remove as soon as the madek:core meta data is part of the test db
          MetaKey.create id: 'madek:core:keywords',
                         meta_datum_object_type: 'MetaDatum::Keyword'
        end

    FactoryGirl.create :meta_datum_text,
                       meta_key: meta_key,
                       collection: collection

    let(:object) { collection }
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :collection }
  end
end
