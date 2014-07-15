# -*- encoding : utf-8 -*-
class MetaTerm < ActiveRecord::Base
  belongs_to :meta_key_definition
  has_many :meta_keys, :through => :meta_key_definitions

  has_and_belongs_to_many :meta_data,
    join_table: :meta_data_meta_terms, 
    foreign_key: :meta_term_id, 
    association_foreign_key: :meta_datum_id

  default_scope lambda{order(:position,:term,:id)}

  scope :with_meta_data, lambda{where(%Q<
    "meta_terms"."id" in (#{joins(:meta_data).select('"meta_terms"."id"') \
                                      .group('"meta_terms"."id"').to_sql}) >)}

  scope :used, ->(are_used = true){
    condition = are_used ? 'EXISTS' : 'NOT EXISTS'
    operator  = are_used ? 'OR'     : 'AND'
    where(%Q<
      #{condition} (SELECT NULL FROM "meta_data_meta_terms" 
                      WHERE "meta_terms"."id" = "meta_data_meta_terms"."meta_term_id")>)}

  scope :not_used, lambda{where(%Q<
    NOT EXISTS (SELECT NULL FROM "meta_data_meta_terms" 
      WHERE "meta_terms"."id" = "meta_data_meta_terms"."meta_term_id")>)}

  def to_s
    term
  end

  ######################################################
 
  def transfer_meta_data_meta_terms_to meta_term_receiver
    meta_term_receiver.meta_data << \
      meta_data \
      .where(%<id not in (#{meta_term_receiver.meta_data.select('"meta_data"."id"').to_sql})>)
    meta_data.destroy_all
  end

  ######################################################

    def is_used?
      meta_data.exists?
    end
  
  ######################################################

    def used_times
      meta_data.count
    end

  ######################################################

    def used_as?(type)
      case type
      when :term
        meta_data.exists?
      else
        false
      end
    end

  scope :text_search, lambda{|search_term| where(term: search_term)}

  scope :text_rank_search, lambda{|search_term| 
    rank= text_search_rank :term, search_term
    select("#{'meta_terms.*,' if select_values.empty?}  #{rank} AS search_rank") \
      .where("#{rank} > 0.05") \
      .reorder("search_rank DESC") }

  scope :trgm_rank_search, lambda{|search_term| 
    rank= trgm_search_rank :term, search_term
    select("#{'meta_terms.*,' if select_values.empty?} #{rank} AS search_rank") \
      .where("#{rank} > 0.05") \
      .reorder("search_rank DESC") }

end
