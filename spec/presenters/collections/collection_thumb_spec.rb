require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'

describe Presenters::Collections::CollectionThumb do
  def all_values(obj)
    if obj.is_a?(Hash)
      obj.values.map { |v| all_values(v) }.flatten
    else
      obj
    end
  end

  it 'dump' do
    c = Collection.all.sample
    p = described_class.new(c, c.responsible_user)
    d = p.dump
    expect(
      all_values(d).all? do |v|
        not v.nil? and not v.match(/ActiveRecord/)
      end
    ).to be true
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :collection }
  end
end
