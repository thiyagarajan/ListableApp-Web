# Collaborators are people with whom a particular list is shared.  We don't want
# to bother people viewing the collaborators list with whether or not a collaborator
# has accepted an invitation or not, so we present a de-duped list of users who have 
# current links to the list as well as the list of active invitees.
class CollaboratorsController < ApplicationController
  before_filter :require_user
  
  skip_before_filter :verify_authenticity_token, :only => :create
  
  before_filter :detect_list
  before_filter :verify_permissions_for_list
  
  def index
    @list = List.find(params[:list_id])
    
    @collaborators = @list.user_list_links(:include => :users)

    respond_to do |format|
      format.html

      format.json do 
        collab_hash = @collaborators.map do |c| 
          {
            :id           => c.id,
            :login        => c.user.login,
            :user_id      => c.user.id,
            :user_image   => Digest::MD5.hexdigest(c.user.email),
            :is_creator   => c.user == @list.creator
          }
        end
        
        render :json => collab_hash
      end
    end
  end
  
  def new
    @collaborator = Listable::Collaborator.new
  end

  # If the given email already exists as a user account, create a link
  # for this account.  Otherwise, generate the user account first and then
  # create a link.
  def create
    @collaborator = Listable::Collaborator.new(params[:collaborator])
    
    @collaborator.list    = @list
    @collaborator.creator = current_user

    unless @user = User.find_by_email(@collaborator.email)
      pw = ('a'..'z').sort_by {rand}[0,15].join  # Give new user a crazy random password
      @user = User.new(:password => pw, :password_confirmation => pw, :email => @collaborator.email, :login => @collaborator.email, :creator => current_user)
    end
    
    if @user.save && link = create_user_list_link(@user, :list => @list, :creator => current_user)
      @collaborator.login = @user.login
      
      msg = "Your list has been shared with #{@collaborator.email}"
      msg += " (Listable user #{@collaborator.login})" unless @collaborator.email == @collaborator.login
      
      Notifier.deliver_new_invitation_notification(current_user, @user, @list)

      flash[:notice] = msg
      
      respond_to do |format|
        format.html do
          redirect_to list_collaborators_path(@list)
        end
        
        format.json { render :status => 200, :json => {:message => ''} }
      end
      
    else

      respond_to do |format|
        format.html do
          if @list.users.find_by_email(@collaborator.email)
            flash[:error] = "User #{@collaborator.email} has already been added to this list."
          else
            flash[:error] = "An unknown error has occurred"
          end
          render :action => :new
        end
        
        format.json { render :status => 400, :json => {:message => 'Unable to subscribe user to list'} }
      end

    end
  end
  
  def destroy
    @user_list_link = UserListLink.find(params[:id])
    
    if @user_list_link.destroy
      respond_to do |format|
        format.html do
          flash[:notice] = "User has been successfully unsubscribed from the list."
          redirect_to list_collaborators_path(@list)
        end

        format.json { render :status => 200, :json => {:message => ''} }
      end

    else
      respond_to do |format|
        format.html do
          flash[:error] = "Failed to unsubscribe user from list"
          redirect_to list_collaborators_path(@list)
        end

        format.json { render :status => 400, :json => {:message => 'Resource could not be deleted'} }
      end
    end
  end
  
  private
  
  # Extracted to separate method for stubbing purposes
  def create_user_list_link(user, params)
    link = user.user_list_links.build(params.except(:list, :creator))
    
    # Set attrs protected by mass assignment checks...
    link.creator  = params[:creator]
    link.list     = params[:list]
    
    link.save
  end
  
end
