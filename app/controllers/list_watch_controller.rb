class ListWatchController < ApplicationController
  before_filter :require_user
  
  before_filter :detect_link
  before_filter :verify_permissions_for_link
  
  def update
    @link.toggle(:watching)
    
    if @link.save
      flash[:notice] = @link.watching? ? "You are now watching this list." : "You are no longer watching this list."
    else
      flash[:error] = "Unable to toggle list watch status.  Please contact support@listableapp.com if problems continue."
    end

    redirect_to list_items_path(@link.list)    
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
