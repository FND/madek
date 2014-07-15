class AttachMetaTermToMetaKeyDefinition < ActiveRecord::Migration

  class ::MetaKey < ActiveRecord::Base
    has_many :meta_key_definitions, dependent: :destroy 
    has_many :meta_key_meta_terms, dependent: :destroy
    has_many :meta_terms, ->{order("meta_keys_meta_terms.position ASC")}, through: :meta_key_meta_terms
    accepts_nested_attributes_for :meta_terms, reject_if: proc { |attributes| attributes[:term].blank? }
  end

  class ::MetaKeyDefinition < ActiveRecord::Base
    belongs_to    :meta_key
  end

  class ::MetaTerm < ActiveRecord::Base
    has_many :meta_key_meta_terms, :foreign_key => :meta_term_id

    has_and_belongs_to_many :meta_data,
      join_table: :meta_data_meta_terms, 
      foreign_key: :meta_term_id, 
      association_foreign_key: :meta_datum_id
  end

  class ::MetaKeyMetaTerm < ActiveRecord::Base
    self.table_name = 'meta_keys_meta_terms'
    belongs_to    :meta_key
    belongs_to    :meta_term, :class_name => "MetaTerm"
  end



  def up
    change_table :meta_terms do |t|
      t.timestamps 
      t.uuid :meta_key_definition_id
      t.integer :position, default: 0, nil: false
    end
    remove_index :meta_terms, :term 
    add_foreign_key :meta_terms, :meta_key_definitions, dependent: :delete


    # use the non existing created_at column to differentiate between 
    # new and old meta_terms
    MetaTerm.where('created_at IS NULL').find_in_batches do |meta_terms| 
      meta_terms.each do |meta_term|

        MetaKeyDefinition.joins(meta_key: {meta_key_meta_terms: :meta_term}) \
          .where("meta_terms.id = ?",meta_term.id).each do |meta_key_definition|

            puts "ATTACH #{meta_term} -> #{meta_key_definition.attributes}"
            meta_key = MetaKey.find meta_key_definition.meta_key_id
            puts "META_KEY #{meta_key}"
            meta_key_meta_term = MetaKeyMetaTerm.find_by meta_term_id: meta_term.id, 
              meta_key_id: meta_key.id
            binding.pry unless meta_key_meta_term
            puts "META_KEY_META_TERM: #{meta_key_meta_term.attributes} \n\n"
            new_meta_term= MetaTerm.create! meta_key_definition_id: meta_key_definition.id,
                term: meta_term.term, position: meta_key_meta_term.position

            new_meta_term.meta_data << meta_term.meta_data

        end

      end
    end

    MetaTerm.where("meta_key_definition_id is NULL").destroy_all
    drop_table :meta_keys_meta_terms

    change_column :meta_terms, :meta_key_definition_id, :uuid, null: false

    add_index :meta_terms, :meta_key_definition_id
    add_index :meta_terms, [:meta_key_definition_id,:term], unique: true
  end

  def down
    raise 'irreversible' 
  end
end
