require 'spec_helper'

describe MetaTermsController do
  include Controllers::Shared
  render_views

  before :each do
    FactoryGirl.create :usage_term 
    @meta_key = FactoryGirl.create :meta_key, id: "Department", :meta_datum_object_type => "MetaDatumMetaTerms", :is_extensible_list => true
    @user = FactoryGirl.create :user
  end

  describe "fetch meta terms providing a meta key id" do

    before :each do
      5.times do
        mr = FactoryGirl.create :media_entry, :user => @user
        mr.meta_data.create :meta_key => @meta_key, :value => [Faker::Lorem.words(4).join(' '), Faker::Lorem.words(4).join(' ')]
      end
    end

    it "gets all meta terms associated to provided meta key id" do
      get :index, {format: 'json', meta_key_id: @meta_key.id}, valid_session(@user)
      expect(response).to be_success
      json = JSON.parse(response.body)
      json.each {|meta_term| expect(meta_term.keys.sort).to eq ["id", "value"] }
    end

  end

end 
