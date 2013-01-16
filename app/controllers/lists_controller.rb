class ListsController < ApplicationController
  before_filter :require_user

  before_filter :detect_list_by_id_or_uuid, :only => [ :update, :destroy ] 
  before_filter :verify_permissions_for_list, :only => [ :update, :destroy ]
  
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def index
    @user = current_user
    
    respond_to do |format|
      format.html
      
      format.json do 
        render :json => lists_to_hash(@user)
      end
      
      format.iphone
    end
  end
  
  def update
    # TODO - slice out the name attribute here, add tests?
    if @list.update_attributes(params[:list])
      render :status => 200, :json => @list.attributes.slice('name')
    else
      render :status => 400, :json => { :message => 'Failed to update list' }
    end
  end

  # Just unsubscribes the user from the list.  User is alerted if they're the last user standing on the current
  # list, as the list will be 'stranded' and may be deleted at some point in the future.
  def destroy
    link = @list.user_list_links.first(:conditions => { :user_id => current_user.id })

    if link.destroy
      respond_to do |format|
        format.html do
          flash[:notice] = "You have been unsubscribed from this list."
          redirect_to lists_path
        end
        
        format.json { render :status => 200, :json => {:message => ''} }
      end
      
    else
      respond_to do |format|
        format.html do
          flash[:error] = @list.errors.full_messages.join(", ")
          redirect_to lists_path
        end
        
        format.json { render :status => 400, :json => {:message => 'Unsubscribe from list failed'} }
      end
    end
  end
  
  def new
    @list = List.new
  end
  
  def create
    @list = List.new(params[:list])

    @list.creator = current_user

    if @list.save
      current_user.lists << @list
      
      respond_to do |format|
        format.html do
          flash[:notice] = "List saved successfully"
          redirect_to list_items_path(@list)
        end

        format.json { render :status => 200, :json => {
            :id   => @list.id,
            :uuid => @list.uuid,
            :name => @list.name,
            :current_user_is_creator => true
          }
        }
      end
      
    else
            
      respond_to do |format|
        format.html do
          flash[:error] = @list.errors.full_messages.join(", ")
          render :action => :new
        end
        
        format.json do
          err_msg = @list.errors.empty? ? "Unable to create new list" : @list.errors.full_messages.join(", ")
          render :status => 400, :json => { :message => err_msg }
        end
      end
      
    end
  end
  
  private 

  def detect_list_by_id_or_uuid
    @list = List.lookup_by_id_or_uuid(params[:id])
  end

  def lists_to_hash(user)
    user.user_list_links.all(:include => :list).map do |l|
      {
        :id           => l.list.id,
        :uuid         => l.list.uuid,
        :name         => l.list.name,
        :link_id      => l.id,
        :current_user_is_creator   => l.list.creator == user
      }
    end
  end
  
end
