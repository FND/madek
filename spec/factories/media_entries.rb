FactoryGirl.define do

  factory :media_entry do
    before(:create) do |me|
      me.responsible_user_id ||= (User.find_random || FactoryGirl.create(:user)).id
      me.creator_id ||= (User.find_random || FactoryGirl.create(:user)).id
    end

    factory :media_entry_with_image_media_file do
      after(:create) do |me|
        FactoryGirl.create :media_file_for_image, media_entry: me
      end
    end

    factory :media_entry_with_audio_media_file do
      after(:create) do |me|
        FactoryGirl.create :media_file_for_audio, media_entry: me
      end
    end
  end


end
