require 'spec_helper'
require Rails.root.join 'spec', 'models', 'shared', 'edit_sessions_spec.rb'
require Rails.root.join 'spec', 'models', 'shared', 'entrusted_to_user_spec.rb'
require Rails.root.join 'spec', 'models', 'shared', 'favoritable_spec.rb'
require Rails.root.join 'spec', 'models', 'shared', 'meta_data_spec.rb'
require Rails.root.join 'spec', 'models', 'shared', 'validates_spec.rb'

describe Collection do

  describe 'Creation' do

    it 'should be producible by a factory' do
      expect { FactoryGirl.create :collection }.not_to raise_error
    end

  end

  describe 'Update' do

    it_validates 'presence of', :responsible_user_id
    it_validates 'presence of', :creator_id

  end

  context 'an existing Collection' do

    it_behaves_like 'a favoritable' do
      let(:resource) { FactoryGirl.create :collection }
    end

    it_has 'edit sessions' do
      let(:resource_type) { :media_entry }
    end
  end

  it_provides_scope 'entrusted to user'

  context 'media_entries association' do

    before :example do
      @collection = FactoryGirl.create(:collection)
      @media_entry = FactoryGirl.create(:media_entry)
    end

    it 'highlights' do
      FactoryGirl.create \
        :collection_media_entry_arc,
        collection: @collection,
        media_entry: @media_entry,
        highlight: true

      expect(@collection.media_entries.highlights.count).to be == 1
      expect(@collection.media_entries.highlights).to include @media_entry
    end

    it 'cover' do
      FactoryGirl.create \
        :collection_media_entry_arc,
        collection: @collection,
        media_entry: @media_entry,
        cover: true

      expect(@collection.media_entries.cover).to be == @media_entry
    end
  end

  it 'collections association' do
    @parent = FactoryGirl.create(:collection)
    @child = FactoryGirl.create(:collection)

    FactoryGirl.create \
      :collection_collection_arc,
      parent: @parent,
      child: @child

    expect(@parent.collections.count).to be == 1
    expect(@parent.collections).to include @child
  end

  it 'filter_sets association' do
    @collection = FactoryGirl.create(:collection)
    @filter_set = FactoryGirl.create(:filter_set)

    FactoryGirl.create \
      :collection_filter_set_arc,
      collection: @collection,
      filter_set: @filter_set

    expect(@collection.filter_sets.count).to be == 1
    expect(@collection.filter_sets).to include @filter_set
  end

  context 'reader methods for meta_data' do

    it_provides_reader_method_for 'meta_datum', 'title'
    it_provides_reader_method_for 'meta_datum', 'description'

  end
end
