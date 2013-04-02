FactoryGirl.define do

  factory :meta_datum_departments do
    meta_key {MetaKey.find_by_id("institutional affiliation") || FactoryGirl.create(:meta_key_institutional_affiliation)}
    media_resource {FactoryGirl.create :media_resource}
  end

end


