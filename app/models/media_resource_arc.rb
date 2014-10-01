class MediaResourceArc < ActiveRecord::Base

  validate :no_self_reference, :only_set_as_parent, :only_media_entry_as_cover
  validates_uniqueness_of :child_id, :scope => :parent_id
  validates_uniqueness_of :cover, :scope => :parent_id, :if => Proc.new {|x| x.cover }
  before_validation :reset_old_cover

  belongs_to  :child, :class_name => "MediaResource",  :foreign_key => :child_id
  belongs_to  :parent, :class_name => "MediaResource",  :foreign_key => :parent_id

  def self.connecting media_resources
    ids = media_resources.map(&:id)
    where("parent_id in (?) and child_id in (?)",ids,ids)
  end

  private 

  def no_self_reference
    if child.id == parent.id
      errors[:base] << "parent and child must not be equal"
    end
  end

  def only_set_as_parent
    if parent.class != MediaSet # TODO accept parent as FilterSet as well ?? unless parent.is_a? MediaSet
      errors[:base] << "only sets can be parents"
    end
  end

  def only_media_entry_as_cover
    if cover and child.class != MediaEntry
      errors[:base] << "only media_entries can be covers"
    end
  end

  def reset_old_cover
    return true unless cover
    old_cover = parent.out_arcs.where(cover:true).first
    return true if old_cover == self
    if old_cover
      old_cover.update_attribute :cover, false
    end
  end

end

