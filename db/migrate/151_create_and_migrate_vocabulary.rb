class CreateAndMigrateVocabulary < ActiveRecord::Migration

  def change
    create_table :vocabularies, id: :string do |t|
      t.text :label
      t.text :description
    end

    add_column :meta_keys, :vocabulary_id, :string

    create_table :vocables, id: :uuid do |t|
      t.string :meta_key_id
      t.text :term
    end

    create_table :meta_data_vocables, id: false do |t|
      t.uuid :meta_datum_id
      t.uuid :vocable_id
    end

  end
  

end
