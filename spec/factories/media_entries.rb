FactoryGirl.define do

  factory :media_entry do
    before(:create) do |me|
    end
  end

  factory :media_entry_with_image_media_file, class: "MediaEntry"  do
    after(:create) do |me|
      #FactoryGirl.create :media_file_for_image, media_entry: me
    end
  end

end

