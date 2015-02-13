require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api_spec'

describe Presenters::MediaEntries::MediaEntryThumb do
  it 'dummy' do
    # for the rspec updator
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :media_entry }
  end

  context 'image_url' do
    it_responds_to 'image_url', 'with preview image' do
      media_entry = FactoryGirl.create(:media_entry_with_image_media_file)
      let(:resource) { media_entry }
      let(:media_entry) { media_entry }
    end

    it_responds_to 'image_url', 'with generic image' do
      media_entry = FactoryGirl.create(:media_entry_with_audio_media_file)
      let(:resource) { media_entry }
      let(:media_entry) { media_entry }
    end
  end
end
