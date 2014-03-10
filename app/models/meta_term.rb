# -*- encoding : utf-8 -*-
class MetaTerm < ActiveRecord::Base
  has_many :meta_key_meta_terms, :foreign_key => :meta_term_id
  has_many :meta_keys, :through => :meta_key_meta_terms

  # TODO include keywords ??
  has_and_belongs_to_many :meta_data,
    join_table: :meta_data_meta_terms, 
    foreign_key: :meta_term_id, 
    association_foreign_key: :meta_datum_id
  has_many :keywords, :foreign_key => :meta_term_id

  validate do
    errors.add(:base, "A term cannot be blank") if LANGUAGES.all? {|lang| send(lang).blank? }
  end

  scope :with_meta_data, lambda{where(%Q<
    "meta_terms"."id" in (#{joins(:meta_data).select('"meta_terms"."id"').group('"meta_terms"."id"').to_sql}) >)}
    # essentially does the same as above with DISTINCT ON instead of GROUP BY, 
    # queries are different but there is no much difference in speed
  scope :with_keywords, lambda{where(%Q<
    "meta_terms"."id" in (#{joins(:keywords).select('DISTINCT ON ("meta_terms"."id") "meta_terms"."id"').to_sql}) >)}

  scope :with_key_labels, lambda{where(%Q<
    "meta_terms"."id" IN (SELECT "label_id" FROM "meta_key_definitions" GROUP BY "label_id") >)}

  scope :with_key_hints, lambda{where(%Q<
    "meta_terms"."id" IN (SELECT "hint_id" FROM "meta_key_definitions" GROUP BY "hint_id") >)}

  scope :with_key_descriptions, lambda{where(%Q<
    "meta_terms"."id" IN (SELECT "description_id" FROM "meta_key_definitions" GROUP BY "description_id") >)}

  scope :is_used, lambda{where(%Q<
    "meta_terms"."id" IN (SELECT "label_id" FROM "meta_key_definitions" GROUP BY "label_id") OR
    "meta_terms"."id" IN (SELECT "hint_id" FROM "meta_key_definitions" GROUP BY "hint_id") OR
    "meta_terms"."id" IN (SELECT "description_id" FROM "meta_key_definitions" GROUP BY "description_id") OR
    "meta_terms"."id" in (#{joins(:meta_data).select('"meta_terms"."id"').group('"meta_terms"."id"').to_sql}) OR
    "meta_terms"."id" in (#{joins(:keywords).select('DISTINCT ON ("meta_terms"."id") "meta_terms"."id"').to_sql}) >)}

  def to_s(lang = nil)
    lang ||= DEFAULT_LANGUAGE
    self.send(lang)
  end

  USAGE = [:key_label, :key_hint, :key_description]

  ######################################################

    def reassign_meta_data_to_term(term, meta_key = nil)
      meta_data_to_reassign = meta_key ? meta_data.where(:meta_key_id => meta_key) : meta_data
      meta_data_to_reassign.each do |md|
        md.value = md.value.map {|x| x == self ? term : x }
        md.save
      end
    end
  
  ######################################################

    def is_used?
      MetaKeyDefinition.where("? IN (label_id, description_id, hint_id)", id).exists? or
      MetaContext.where("? IN (label_id, description_id)", id).exists? or
      meta_key_meta_terms.exists? or
      keywords.exists? or
      meta_data.exists?
    end
  
  ######################################################

    def used_times
      MetaKeyDefinition.where("? IN (label_id, description_id, hint_id)", id).count +
      MetaContext.where("? IN (label_id, description_id)", id).count +
      meta_key_meta_terms.count +
      keywords.count +
      meta_data.count
    end

  ######################################################

    def used_as?(type)
      case type
      when :term
        meta_data.exists?
      when :keyword
        keywords.exists?
      when :key_label
        MetaKeyDefinition.where(label_id: id).exists?
      when :key_hint
        MetaKeyDefinition.where(hint_id: id).exists?
      when :key_description
        MetaKeyDefinition.where(description_id: id).exists?
      else
        false
      end
    end

  ######################################################

  # OPTIMIZE 2210 uniqueness
  def self.find_or_create(h)
    if h.is_a? MetaTerm
      h
    elsif h.is_a? Integer
      find_by_id(h)
    elsif h.is_a? String
      l = {}
      LANGUAGES.each do |lang|
        l[lang] = h
      end
      find_or_create_by_en_gb_and_de_ch(l)
    elsif h.values.any? {|x| not x.blank? }
      find_or_create_by h
    end
  end

end
