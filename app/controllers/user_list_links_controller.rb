class UserListLinksController < ApplicationController
  before_filter :require_user
  
  before_filter :detect_link
  before_filter :verify_permissions_for_link
  
  def update
    # Take care of any reordering that has to happen through the plugin.
    if params[:user_list_link].include?(:position)
      @link.insert_at(params[:user_list_link][:position])
    end
    
    if @link.save
      
      respond_to do |format|
        format.json { render :status => 200, :json => {:message => ''}}
      end
      
    else
      
      respond_to do |format|
        msg = "Failed to update item. Errors: #{@link.errors.full_messages.join(', ')}"
        format.json { render :status => 400, :json => {:message => msg} }
      end
    end
    
  end
  
  private
  
  def detect_link
    @link = UserListLink.find(params[:id])
  end
  
  # Redirect to home page with error if user doesn't have permissions for this list
  def verify_permissions_for_link
    unless current_user.user_list_links.include?(@link)
      respond_to do |format|
        format.html do
          flash[:error] = "You don't have permission to access this list"
          redirect_to '/'
        end
      
        format.json { render :status => 403, :json => {:message => 'Unable to access requested list'} }      
      end
    end
    
    return false
  end

end
