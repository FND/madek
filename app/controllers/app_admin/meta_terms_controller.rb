class AppAdmin::MetaTermsController < AppAdmin::BaseController
  def index
    begin
      @meta_terms = MetaTerm.page(params[:page]).per(12)
      @filter_by = reset_params? ? nil : (params.try(:[], :filter_by) || nil)
      @sort_by = reset_params? ? :asc : (params.try(:[], :sort_by) || :asc)

      @search_terms = reset_params? ? nil : params.try(:[],:filter).try(:[],:search_terms)

      if !@search_terms.blank?
        @search_terms = @search_terms.strip
        case params.try(:[], :sort_by) 
        when 'trgm_rank'
          @meta_terms= @meta_terms.trgm_rank_search(@search_terms)
        when 'text_rank'
          @meta_terms= @meta_terms.text_rank_search(@search_terms)
        else
          @meta_terms= @meta_terms.text_search(@search_terms)
        end
      end

      case @filter_by
      when 'used'
        @meta_terms = @meta_terms.used
      when 'not_used'
        @meta_terms = @meta_terms.used(false)
      when 'term'
        @meta_terms = @meta_terms.with_meta_data
      else
      end

      case @sort_by
      when 'asc'
        @meta_terms = @meta_terms.order('term ASC')
      when 'desc'
        @meta_terms = @meta_terms.order('term DESC')
      when 'trgm_rank'
        @sort_by = :trgm_rank
        raise "Search term must not be blank!" if @search_terms.blank? 
      when 'text_rank'
        @sort_by = :text_rank
        raise "Search term must not be blank!" if @search_terms.blank? 
      else
        @meta_terms= @meta_terms.order('term ASC')
      end

    rescue Exception => e
      @meta_terms = MetaTerm.where("true = false").page(params[:page])
      @error_message= e.to_s
    end
  end

  def edit
    @meta_term = MetaTerm.find(params[:id])
  end

  def update
    begin
      @meta_term = MetaTerm.find(params[:id])
      @meta_term.update_attributes! meta_term_params
      redirect_to app_admin_meta_terms_url, flash: {success: "A meta term has been updated"}
    rescue => e
      redirect_to edit_app_admin_meta_term_url(@meta_term), flash: {error: e.to_s}
    end
  end

  def destroy
    begin
      @meta_term = MetaTerm.find(params[:id])
      unless @meta_term.used?
        @meta_term.destroy
        flash = {success: "The Meta Term has been deleted."}
      else
        flash = {error: "The Meta Term is used and cannot be deleted."}
      end
      redirect_to app_admin_meta_terms_url, flash: flash
    rescue => e
      redirect_to :back, flash: {error: e.to_s}
    end
  end

  def form_transfer_resources
    @meta_term = MetaTerm.find(params[:id])
  end

  def transfer_resources
    begin
      @meta_term_originator = MetaTerm.find(sanitize_id(params[:id]))
      @meta_term_receiver   = MetaTerm.find(sanitize_id(params[:id_receiver]))
      ActiveRecord::Base.transaction do
        @meta_term_originator.transfer_meta_data_meta_terms_to @meta_term_receiver
        @meta_term_receiver.reload.meta_data.reload.map(&:media_resource).each(&:reindex)
      end
      redirect_to app_admin_meta_terms_path, flash: {success: "The meta term's resources have been transferred"}
    rescue => e
      redirect_to app_admin_meta_terms_path, flash: {error: e.to_s}
    end
  end

  def default_url_options(options={})
    {
      "filter[search_terms]" => params.try(:[], :filter).try(:[], :search_terms),
      :sort_by               => params[:sort_by] || :de_ch_asc,
      :filter_by             => params[:filter_by]
    }
  end

  private
  def meta_term_params
    params.require(:meta_term).permit(:term)
  end

  def reset_params?
    params[:reset].present?
  end
end
