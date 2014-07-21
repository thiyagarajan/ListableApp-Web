class ItemsController < ApplicationController
  before_filter :require_user
  
  before_filter :detect_list
  before_filter :verify_permissions_for_list

  skip_before_filter :verify_authenticity_token, :only => :create
  
  def show
    @item = if params[:id] =~ Listable::Constants::UUID_RE
      @list.items.find_by_uuid!(params[:id], :include => :creator) 
    else
      @list.items.find(params[:id], :include => :creator)
    end
    
    respond_to do |format|
      format.json do
        item_attrs = @item.attributes.slice('id', 'uuid', 'name', 'created_at')
        creator_login = @item.creator.nil? ? "" : @item.creator.login
        item_attrs = item_attrs.merge('creator_login' => creator_login, 'type' => 'Item')
        
        render :json => item_attrs
      end
    end
  end

  def index
    
    # Need the user list link to allow the user to watch or unwatch.
    @link = UserListLink.first(:conditions => { :user_id => current_user.id, :list_id => @list.id })

    respond_to do |format|
      format.html
      format.iphone

      format.json do
        render :json => items_to_hash(ordered_items(@list))
      end
    end      
        
  end
  
  def update
    item = @list.items.find(params[:id])
    
    item.changed_by = current_user
    
    if params[:item].include?(:position)
      new_position  = params[:item][:position]
      params[:item] = params[:item].except(:position)
      item.insert_at(new_position)
    end
    
    if item.update_attributes(params[:item])
      
      # If this item is changing scopes, make it the first in the list.
      if params['item']['completed']
        item.position = 1
        item.save
      end

      respond_to do |format|
        format.json do
          render :status => 200, :json => item.attributes.slice('name')
        end

        format.html do
          redirect_to list_items_path(@list)
        end
      end
    else

      respond_to do |format|
        format.json do
          render :status => 400, :json => {:body => "Failed to update item. Errors: #{item.errors.full_messages.join(', ')}" }
        end

        format.html do
          redirect_to list_items_path(@list)
        end
      end
    end

    return
  end
  
  def destroy    
    unless @item = Item.first(:conditions => { :id => params[:id], :list_id => @list.id })
      raise ActiveRecord::RecordNotFound, "Couldn't find Item with ID=#{params[:id]} in list #{@list.id}"
    end
    
    if @item.destroy
      respond_to do |format|
        format.html do
          flash[:notice] = "Item successfully deleted"
          redirect_to list_items_path(@list)
        end
        
        format.json do
          render :status => 200, :json => {:message => ''}
        end
      end
      
    else
      respond_to do |format|
        format.html do
          flash[:error] = "Failed to destroy item"
          redirect_to list_items_path(@list)
        end

        format.json do
          render :status => 400, :json => {:message  => 'Resource could not be deleted'}
        end
      end
    end
  end
  
  def create

    @item = Item.new(params[:item])

    @item.creator = current_user
    @item.list    = @list
    @item.last_updated = Date.today
    @item.last_updated_by = current_user.id 

    if @item.save
      render :status => 200, :json => { :message => '' }
    else
      render :status => 400, :json => { :message => 'Resource could not be created' }
    end
  end
  
  private

  def ordered_items(list)
    scope = list.items

    scope = scope.with_name_like(params[:keyword]) if params[:keyword].present?

    scope = if params[:sort].present? && params[:sort] == 'Alphabetical'
      scope.sorted_alphabetically
    else
      scope.ordered_by_completed_status_and_position
    end

    scope    
  end

  def items_to_hash(items)
    items.map do |it|
      {
        :id         => it.id,
        :uuid       => it.uuid,
        :name       => it.name,
        :completed  => it.completed,
        :position   => it.position
      }
    end
  end
end
