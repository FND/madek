require "spec_helper"
require "spec_helper_feature"
require 'spec_helper_feature_shared'

feature "Searching for an updated meta datum" do

  scenario "setting the subtitle and searching for it 
    should yield the media resource", browser: :headless do

    @current_user= sign_in_as 'normin'
    @media_entry= create_a_media_entry
    set_media_resource_title @media_entry, "THE NEW ENTRY" 
    visit media_entry_path(@media_entry)
    expect(page).to have_content "THE NEW ENTRY"
    click_on_text "Weitere Aktionen"
    click_on_text "Metadaten editieren" 
    find_input_for_meta_key("subtitle").set("jabberwocky")
    click_on_text "Speichern"
    click_on_text "Suche"
    find_input_with_name("terms").set("jabberwocky")
    submit_form
    expect(page).to have_content "THE NEW ENTRY"

  end


  def create_a_media_entry
    FactoryGirl.create :media_entry_with_image_media_file, 
      user: @current_user
  end

  def find_input_with_name name
    find("textarea,input[name='#{name}']")
  end

  def find_input_for_meta_key name
    find("fieldset[data-meta-key='#{name}']").find("textarea,input")
  end

  def set_media_resource_title media_resource , title
    media_resource.meta_data \
      .create meta_key: MetaKey.find_by_id(:title), value: title
  end

end

