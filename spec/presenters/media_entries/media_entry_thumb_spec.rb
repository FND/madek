require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'

describe Presenters::MediaEntries::MediaEntryThumb do
  it 'dummy' do
    # for the rspec updator
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :media_entry }
  end

  context 'image_url' do
    it 'preview image' do
      media_entry = FactoryGirl.create(:media_entry_with_image_media_file)
      presenter = described_class.new(media_entry, media_entry.responsible_user)
      expect(presenter.image_url).to be == \
        Rails.application.routes.url_helpers
          .media_entry_image_path(media_entry, :small)
    end

    it 'generic image' do
      media_entry = FactoryGirl.create(:media_entry_with_audio_media_file)
      presenter = described_class.new(media_entry, media_entry.responsible_user)
      expect(presenter.image_url).to be == \
        ActionController::Base.helpers.image_path(GENERIC_THUMBNAIL_IMAGE_ASSET)
    end
  end
end
