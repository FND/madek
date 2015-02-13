require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api_spec'

describe Presenters::Collections::CollectionThumb do
  it 'dummy' do
    # for the rspec updator
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :collection }
  end

  context 'image url' do
    it_responds_to 'image_url', 'with preview image' do
      collection = FactoryGirl.create(:collection)
      media_entry = FactoryGirl.create(:media_entry_with_image_media_file)
      collection.media_entries << media_entry

      let(:resource) { collection }
      let(:media_entry) { media_entry }
    end

    it_responds_to 'image_url', 'with generic image' do
      collection = FactoryGirl.create(:collection)
      media_entry = FactoryGirl.create(:media_entry_with_audio_media_file)
      collection.media_entries << media_entry

      let(:resource) { collection }
      let(:media_entry) { media_entry }
    end
  end
end
