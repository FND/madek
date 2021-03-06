class AppAdmin::UsersController < AppAdmin::BaseController
  include Concerns::SetSession

  def index
    respond_to do |format|
      format.json {
        users = Person.hacky_search(params[:query]).map(&:user).compact
        render :json => view_context.json_for(users)
      }
      format.html {
        begin
          @users = User.with_resources_amount

          @users = @users.page(params[:page])

          @search_terms  = params.try(:[], :filter).try(:[], :search_terms)
          @admins_filter = params.try(:[], :filter).try(:[], :admins) == 'true'

          if ! @search_terms.blank?
            @search_terms = @search_terms.strip
            case params.try(:[], :sort_by) 
            when 'trgm_rank'
              @users = @users.trgm_rank_search(@search_terms) \
                .joins(:person).order("people.last_name ASC, people.first_name ASC")
            when 'text_rank'
              @users = @users.text_rank_search(@search_terms) \
                .joins(:person).order("people.last_name ASC, people.first_name ASC")
            else
              @users = @users.text_search(@search_terms)
            end
          end

          if @admins_filter
            @admins_filter = true
            @users = @users.admin_users
          end

          # reorder has to come after text-search; 
          # textacular orders by ranking which might cut off results
          case params.try(:[], :sort_by) || 'last_name_first_name'
          when 'resources_amount'
            @sort_by = :resources_amount
            @users = @users.sort_by_resouces_amount
          when 'last_name_first_name'
            @sort_by= :last_name_first_name
            @users = @users.joins(:person).reorder("people.last_name ASC, people.first_name ASC")
          when 'login'
            @sort_by = :login
            @users = @users.reorder("login ASC")
          when 'trgm_rank'
            @sort_by = :trgm_rank
            raise "Search term must not be blank!" if @search_terms.blank? 
          when 'text_rank'
            @sort_by = :text_rank
            raise "Search term must not be blank!" if @search_terms.blank? 
          end
        rescue Exception => e
          @users = User.where("false = true").page(0)
          @error_message= e.to_s
        end
      }
    end
  end

  def autocomplete_search 
    @users = User.reorder(:autocomplete).where("autocomplete ilike ?","#{params[:search_term]}%").limit(50)
    render json: @users.map(&:autocomplete)
  end

  def search 
    @users = User.text_search(params[:search_term]).limit(50).order_by_last_name_first_name
    render json: @users.map{|u| {name: u.name, login: u.login}}
  end

  def show
    @user = User.find params[:id]
    @groups =  @user.groups
    @groups = @groups.page(params[:page])
  end

  def edit
    @user = User.find params[:id]
  end

  def new 
    @user = User.new
  end

  def update
    begin
      @user = User.find(params[:id])
      @user.update_attributes! user_params
      redirect_to app_admin_user_url(@user), flash: {success: "The user has been updated."}
    rescue => e
      redirect_to edit_app_admin_user_url(@user), flash: {error: e.to_s}
    end
  end


  def create
    begin
      @user = User.create! user_params
      redirect_to app_admin_user_url(@user), flash: {success: "A new user has been created."}
    rescue => e
      redirect_to new_app_admin_user_url, flash: {error: e.to_s}
    end
  end


  def create_with_user
    begin
      ActiveRecord::Base.transaction do
        @person = Person.create! person_params
        @user = User.create! user_params.merge({person: @person}) 
        redirect_to app_admin_users_url, flash: {success: "A new user with person has been created!"}
      end
    rescue => e
      redirect_to app_admin_users_url, flash: {error: e.to_s}
    end
  end

  def destroy 
    begin 
      User.destroy(params[:id])
      redirect_to app_admin_users_url, flash: {success: "The user has been destroyed!"}
    rescue => e
      redirect_to app_admin_users_url, flash: {error: e.to_s}
    end
  end

  def remove_user_from_group
    begin
      @group = Group.find params[:group_id]
      @group.users.delete User.find(params[:id])
      redirect_to app_admin_group_url(@group), flash: {success: "The user has been removed."}
    rescue => e
      redirect_to app_admin_group_url(@group), flash: {error: e.to_s}
    end
  end

  def switch_to
    reset_session
    set_madek_session(User.find(params[:id]))
    redirect_to root_url
  end

  def reset_usage_terms
    @user = User.find(params[:id])
    @user.reset_usage_terms

    redirect_to app_admin_users_url
  end

  def add_to_admins
    user = User.find(params[:id])
    AdminUser.create!(user: user)

    redirect_to app_admin_users_url, flash: {success: "The user has become an admin."}
  rescue => e
    redirect_to app_admin_users_url, flash: {error: e.message}
  end

  def remove_from_admins
    AdminUser.find_by(user_id: params[:id]).destroy!

    redirect_to app_admin_users_url, flash: {success: "The user has been removed from admins."}
  rescue => e
    redirect_to app_admin_users_url, flash: {error: e.to_s}
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def person_params
    params.require(:person).permit!
  end

end
