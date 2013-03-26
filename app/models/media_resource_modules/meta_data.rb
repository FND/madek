# -*- encoding : utf-8 -*-
#
module MediaResourceModules
  module MetaData
    def self.included(base)
      base.class_eval do 


       # TODO observe bulk changes and reindex once
        has_many :meta_data, :dependent => :destroy do #working here#7 :include => :meta_key
          def get(key, build_if_not_found = true)
            key_id = if key.is_a? MetaKey
              key.id
            elsif not key.is_a? Fixnum
              MetaKey.find_by_label(key).id
            else
              key
            end
            r = where(:meta_key_id => key_id).first
            r ||= build(:meta_key_id => key_id) if build_if_not_found
            r
          end

          def get_value_for(key_id)
            get(key_id).to_s
          end

          def get_for_labels(labels)
            joins(:meta_key).where(:meta_keys => {:label => labels})
          end

          #def with_labels
          #  h = {}
          #  all.each do |meta_datum|
          #    next unless meta_datum.meta_key # FIXME inconsistency: there are meta_data referencing to not existing meta_key_ids [131, 135]
          #    h[meta_datum.meta_key.label] = meta_datum.to_s
          #  end
          #  h
          #end
          def concatenated
            all.map(&:to_s).join('; ')
          end

          def for_context(context = MetaContext.core, build_if_not_exists = true)
            meta_keys = context.meta_keys
            meta_key_ids = context.meta_key_ids

            mds = where(:meta_key_id => meta_key_ids).eager_load(:meta_key)
            mds = mds.eager_load(:keywords => :meta_term) if meta_keys.map(&:label).include?("keywords")
  
            already_ids = mds.map(&:meta_key_id)
            mds += meta_keys.select{|x| x.is_dynamic? and not already_ids.include?(x.id) }.flat_map do |key|
              build(:meta_key => key)
            end
  
            if build_if_not_exists
              already_ids = mds.map(&:meta_key_id)
              mds += (meta_key_ids - already_ids).flat_map do |key_id|
                build(:meta_key_id => key_id)
              end
            end

            mds.sort_by {|md| meta_key_ids.index(md.meta_key_id) } 
          end
        end


        accepts_nested_attributes_for :meta_data, :allow_destroy => true,
          :reject_if => proc { |attributes| attributes['value'].blank? and attributes['_destroy'].blank? }
        # NOTE the check on _destroy should be automatic, check Rails > 3.0.3

        # TODO remove, it's used only on tests!
        def self.find_by_title(title)
          MediaResource.joins(:meta_data => :meta_key).where(:meta_keys => {:label => "title"}, :meta_data => {:string => title})
        end

        def title
          t = meta_data.get_value_for("title")
          t = "Ohne Titel" if t.blank?
          t
        end

        def description
          t = meta_data.get_value_for("description")
        end

        def author
          t = meta_data.get_value_for("author")
        end

        def update_attributes_with_pre_validation(attributes)
          # we need to deep copy the attributes for batch edit (multiple resources)
          dup_attributes = Marshal.load(Marshal.dump(attributes)).deep_symbolize_keys

          if dup_attributes[:meta_data_attributes]
            # To avoid overriding at batch update: remove from attribute hash if :keep_original_value and value is blank
            dup_attributes[:meta_data_attributes].delete_if { |key, attr| attr[:keep_original_value] and attr[:value].blank? }

            dup_attributes[:meta_data_attributes].each_pair do |key, attr|
              if attr[:value].is_a? Array and attr[:value].all? {|x| x.blank? }
                attr[:value] = nil
              end
              # find existing meta_datum, if it exists
              if attr[:id].blank?
                if attr[:meta_key_label]
                  attr[:meta_key_id] ||= MetaKey.find_by_label(attr.delete(:meta_key_label)).try(:id)
                end
                if (md = meta_data.where(:meta_key_id => attr[:meta_key_id]).first)
                  attr[:id] = md.id
                end
              else
                attr.delete(:meta_key_label)
              end

              # get rid of meta_datum if value is blank
              if !attr[:id].blank? and attr[:value].blank?
                attr[:_destroy] = true
                #old# attr[:value] = "." # NOTE bypass the validation
              end
            end
          end
          update_attributes_without_pre_validation(dup_attributes)
        end
      
        alias_method_chain :update_attributes, :pre_validation

        def context_valid?(context = MetaContext.core)
          meta_data.for_context(context).all? {|meta_datum| meta_datum.context_valid?(context) }
        end

      end
    end
  end
end


