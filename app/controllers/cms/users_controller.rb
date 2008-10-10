class Cms::UsersController < Cms::ResourceController
  layout 'cms/administration'
  
  after_filter :update_group_membership, :only => [:update, :create]
  
  def index
    query, conditions = [], []
    
    unless params[:show_expired]
      query << "expires_at IS NULL OR expires_at > ?"
      conditions << Time.now
    end

    unless params[:key_word].blank?
      query << "login LIKE ? OR email LIKE ? OR first_name LIKE ? OR last_name LIKE ?"
      4.times { conditions << "%#{params[:key_word]}%" }
    end
    
    unless params[:group_id].to_i == 0
      query << "user_group_memberships.group_id = ?"
      conditions << params[:group_id]
    end
    
    query.collect! { |q| "(#{q})"}
    conditions = conditions.insert(0, query.join(" AND "))
    
    @users = User.find(:all, :include => :groups, :conditions => conditions)
  end

  def change_password
    user
  end

  def disable
    user.disable!
    redirect_to :action => "index"
  end
  
  def enable
    user.enable!
    redirect_to :action => "index"
  end

  protected
    def after_create_url
      index_url
    end

    def after_update_url
      index_url
    end

    def update_group_membership
      @object.group_ids = params[:group_ids] unless params[:on_fail_action] == "change_password"
    end

  private
    def user
      @user ||= User.find(params[:id])
    end
end