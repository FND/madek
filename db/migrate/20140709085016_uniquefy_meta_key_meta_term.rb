class UniquefyMetaKeyMetaTerm < ActiveRecord::Migration
  class MetaTerm < ActiveRecord::Base
  end

  def change
    remove_foreign_key :meta_keys_meta_terms, :meta_keys
    remove_foreign_key :meta_keys_meta_terms, :meta_terms
    add_foreign_key :meta_keys_meta_terms, :meta_keys, dependent: :delete
    add_foreign_key :meta_keys_meta_terms, :meta_terms, dependent: :delete
    MetaTerm.find_by(term: :Basis).try(&:destroy)
    add_index :meta_keys_meta_terms, [:meta_key_id,:meta_term_id], unique: true
  end
end
