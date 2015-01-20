require 'spec_helper'

[
  'favoritable_spec.rb',
  'edit_sessions_spec.rb',
  'entrusted_to_user_spec.rb',
  'validates_spec.rb',
  'favored_by_user_spec.rb',
  'in_responsibility_of_user_spec.rb',
  'created_by_user_spec.rb'
]
  .each do |file|
  require Rails.root.join 'spec', 'models', 'shared', file
end

##########################################################

describe MediaEntry do

  context 'Creation' do

    it 'should be producible by a factory' do
      expect { FactoryGirl.create :media_entry }.not_to raise_error
    end

  end

  describe 'Update' do

    it_validates 'presence of', :responsible_user_id
    it_validates 'presence of', :creator_id

  end

  context 'an existing MediaEntry' do

    it_behaves_like 'a favoritable' do
      let(:resource) { FactoryGirl.create :media_entry }
    end

    it_has 'edit sessions' do
      let(:resource_type) { :media_entry }
    end

  end

  it_provides_scope 'entrusted to user'
  it_provides_scope 'favored by user'
  it_provides_scope 'in responsibility of user'
  it_provides_scope 'created by user'

end
