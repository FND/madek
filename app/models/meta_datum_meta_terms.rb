# -*- encoding : utf-8 -*-
 
class MetaDatumMetaTerms < MetaDatum
  has_and_belongs_to_many :meta_terms, 
    join_table: :meta_data_meta_terms, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :meta_term_id

  SEPARATOR = "; "

  def to_s
    value.map(&:to_s).join(SEPARATOR)
  end

  def value
    meta_terms
  end

  def value=(new_value)    
    new_meta_terms = Array(new_value).flat_map do |v|
      if v.is_a?(MetaTerm)
        v
      elsif UUID_V4_REGEXP.match v 
        MetaTerm.find_by id: v
      elsif meta_key.is_extensible_list?
        term = MetaTerm.find_or_initialize_by term: v
        meta_key.meta_terms << term unless meta_key.meta_terms.include?(term)
        term
      elsif v.is_a?(String) # the meta_key is not extensible list
        # WTF
        r = meta_key.meta_terms.find_by term: v
        r ||= v.split(SEPARATOR).map do |term| # reconvert string to array, in case reimporting previously exported media_resources
          meta_key.meta_terms.find_or_initialize_by term: term
        end
        r
      else
        v
      end
    end
    
    if new_meta_terms.include? nil
      # TODO add to errors doesn't persist
      #errors.add(:value)
      #media_resource.errors.add(:meta_data)
      raise "invalid value"
    else
      meta_terms.clear
      meta_terms << new_meta_terms
    end
  end

end


