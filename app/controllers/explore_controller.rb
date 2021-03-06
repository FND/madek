class ExploreController < ApplicationController

  respond_to 'html'

  before_filter do
    @featured_set = MediaSet.find_by_id @app_settings.featured_set_id 
    @featured_set_children = @featured_set.included_resources_accessible_by_user(current_user,:view) \
      .ordered_by(:updated_at).limit(6) if @featured_set
    @catalog_set = MediaSet.find_by_id @app_settings.catalog_set_id
    @any_top_keywords = Keyword.with_count_for_accessible_media_resources(current_user).exists?
    @any_context = current_user.individual_contexts.exists?
  end

  def index 
    @teaser_set = MediaSet.find @app_settings.teaser_set_id
    if @teaser_set
      resources = @teaser_set.included_resources_accessible_by_user(current_user, :view)
      @ids = resources.pluck(:id)
      @ids = @ids.shuffle
      @teaser_set_included_resources = []
      10.times do |i|
        @teaser_set_included_resources += resources.where(id: @ids[i])
      end
      #@teaser_set_included_resources = resources.where(id: @ids)
    end
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
    @top_keywords = view_context.hash_for Keyword.with_count_for_accessible_media_resources(current_user).limit(12), {:count => true}
    @contexts = current_user.individual_contexts.limit(4)
  end

  def catalog
    @catalog_set_categories = @catalog_set.categories.where(:view => true) if @catalog_set
  end
 
  def category
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
    @category_set = MediaResource.accessible_by_user(current_user,:view).find(params[:category])
    @category_sections = @category_set.sections view_context.hash_for_filter(@category_set.included_resources_accessible_by_user(current_user,:view), [:meta_data]) if @category_set
  end

  def section
    @catalog_set_categories = @catalog_set.categories.where(:view => true).limit(6) if @catalog_set
    @category_set = MediaResource.accessible_by_user(current_user,:view).find(params[:category])
    @category_sections = @category_set.sections view_context.hash_for_filter(@category_set.included_resources_accessible_by_user(current_user,:view), [:meta_data]) if @category_set
    @current_section = @category_sections.detect{|s| s[:id] == params[:section]}
  end

  def featured_set
    @featured_set_children = @featured_set.included_resources_accessible_by_user(current_user,:view).ordered_by(:updated_at) if @featured_set
  end

  def keywords
    @keywords = view_context.hash_for Keyword.with_count_for_accessible_media_resources(current_user).limit(200), {:count => true}
  end

  def contexts
    @contexts = current_user.individual_contexts
  end

end
