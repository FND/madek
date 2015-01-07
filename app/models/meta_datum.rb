class MetaDatum < ActiveRecord::Base

  class << self
    def new_with_cast(*args, &block)
      if self < MetaDatum
        new_without_cast(*args, &block)
      else
        raise 'MetaDatum is abstract; instatiate a subclass'
      end
    end
    alias_method_chain :new, :cast

  end

  ########################################

  belongs_to :meta_key

  belongs_to :media_entry
  belongs_to :collection
  belongs_to :filter_set
end
