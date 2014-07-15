class AddTermsPositionIndex < ActiveRecord::Migration
  def change
    add_index :meta_terms, :position
  end
end
