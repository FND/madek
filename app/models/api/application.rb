class API::Application < ActiveRecord::Base
  belongs_to :user
  
  attr_accessor :authorization_header

  default_scope lambda{ reorder(id: :asc) }

  validates :id, format: {with: /\A[a-z][a-z0-9_-]+\z/, 
                          message: %[only alpha-numeric ascii characters as well as dashes and underscores are allowed, 
                                    first character must be a letter, all letters must be lowercase]}
  validates :id, length: {in: 3..20}

  def authorization_header_value
    "Basic #{::Base64.strict_encode64("#{id}:#{secret}")}"
  end

  def authorization_header 
    %[Authorization: #{authorization_header_value}]
  end

  def attributes_with_authorization_header
    attributes.merge("authorization_header" => authorization_header)
  end

  def authorized?(action, resource_or_resources)
    Array(resource_or_resources).all? do |resource|
      MediaResource.where(id: resource)  \
        .accessible_by_api_application(self,action).count > 0
    end
  end



end
