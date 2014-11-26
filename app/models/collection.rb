class Collection < ActiveRecord::Base 

  include Concerns::Favoritable

  has_many :collection_media_entry_arcs

  has_many :media_entries, through: :collection_media_entry_arcs

  has_many :keywords

  default_scope { reorder(:created_at,:id) }

  has_and_belongs_to_many :users_who_favored, join_table: "favorite_collections", class_name: "User"

end
