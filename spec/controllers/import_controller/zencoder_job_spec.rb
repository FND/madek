require 'spec_helper'

describe ImportController do
  include Controllers::Shared
  render_views

  before :each do
    Settings.add_source! (Rails.root.join "spec","data","zencoder.yml").to_s
    Settings.reload!
    FactoryGirl.create :usage_term
    FactoryGirl.create :meta_key, id: "copyright status", :meta_datum_object_type => "MetaDatumCopyright"
    FactoryGirl.create :meta_key, id: "description author", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, id: "description author before import", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, id: "uploaded by", :meta_datum_object_type => "MetaDatumUsers"
    FactoryGirl.create :context, id: 'upload'
    FactoryGirl.create :io_interface
    @user = FactoryGirl.create :user
    @media_entry_incomplete_for_image= (FactoryGirl.create :media_entry_incomplete_for_image, user: @user)
    @media_entry_incomplete_for_movie= (FactoryGirl.create :media_entry_incomplete_for_movie, user: @user)
  end

  it "is redirects to the dashboard" do
    post :complete, {}, valid_session(@user)
    expect(response).to redirect_to(my_dashboard_path)
  end

  context "after the post action" do

    before :each do
      post :complete, {}, valid_session(@user)
      @media_entry_for_movie =  MediaEntry.find_by_id(@media_entry_incomplete_for_movie.id)
      @media_entry_for_image = MediaEntry.find_by_id(@media_entry_incomplete_for_image.id)
    end

    describe "the media_entry_for_image" do
      it "is converted to an media_entry from media_entry_incomplete " do
        expect(@media_entry_for_image).to be
      end
      
      it "its media_file doesn't have a most_recent_zencoder_job" do
        expect(@media_entry_for_image.media_file.most_recent_zencoder_job).to be_nil
      end
    end

    describe "the media_entry_for_movie" do

      it "is converted to an media_entry from media_entry_incomplete " do
        expect(@media_entry_for_movie).to be
      end

      it "its media_file has an most_recent_zencoder_job" do
        expect(@media_entry_for_movie.media_file.most_recent_zencoder_job).to be
      end

      describe "the most_recent_zencoder_job" do
        before :each do 
          @most_recent_zencoder_job= @media_entry_for_movie.media_file.most_recent_zencoder_job
        end

        it "has the state 'failed'" do
          expect(@most_recent_zencoder_job.state).to eq "submitted"
        end

      end

    end

  end
  
end


