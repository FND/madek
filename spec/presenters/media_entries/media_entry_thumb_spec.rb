require 'spec_helper'

describe Presenters::MediaEntries::MediaEntryThumb do

  context 'privacy status' do

    before :example do
      @user = FactoryGirl.create(:user)
    end

    it 'public' do
      media_entry = FactoryGirl.create(:media_entry,
                                       responsible_user: @user,
                                       get_metadata_and_previews: true)
      presenter = described_class.new(media_entry, @user)
      expect(presenter.privacy_status).to be == :public
    end

    context 'shared' do

      after :example do
        @presenter = described_class.new(@media_entry, @user)
        expect(@presenter.privacy_status).to be == :shared
      end

      it 'responsible user entrusted resource to other user' do
        @media_entry = FactoryGirl.create(:media_entry,
                                         responsible_user: @user)
        FactoryGirl.create(:media_entry_user_permission,
                           get_metadata_and_previews: true,
                           media_entry: @media_entry)
      end

      it 'responsible user entrusted resource to other group' do
        @media_entry = FactoryGirl.create(:media_entry,
                                         responsible_user: @user)
        FactoryGirl.create(:media_entry_group_permission,
                           get_metadata_and_previews: true,
                           media_entry: @media_entry)
      end

      it 'entrusted to user' do
        @media_entry = FactoryGirl.create(:media_entry)
        FactoryGirl.create(:media_entry_user_permission,
                           user: @user,
                           get_metadata_and_previews: true,
                           media_entry: @media_entry)
      end

    end

    it 'private' do
      media_entry = FactoryGirl.create(:media_entry,
                                       responsible_user: @user)
      presenter = described_class.new(media_entry, @user)
      expect(presenter.privacy_status).to be == :private
    end

  end
end
