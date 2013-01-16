# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  include ExceptionNotifiable 
  
  helper :all # include all helpers, all the time

  before_filter :adjust_format_for_iphone

  protect_from_forgery 
    
  filter_parameter_logging :password, :password_confirmation
      
  helper_method :current_user_session, :current_user

  rescue_from ActiveRecord::RecordNotFound, :with => :resource_not_found

  # Don't render a template for xhr (Rails AJAX helper) methods, from:
  # http://api.rubyonrails.org/classes/ActionView/Helpers/PrototypeHelper.html#M001645
  layout proc{ |c| c.request.xhr? ? false : "application" }    
  
  private
  
  def self.block_ssl_redirect?
    Rails.env.development? || Rails.env.test?
  end
  
  def resource_not_found
    respond_to do |format|
      format.json { render :json => {:message => 'Record not found'}, :status => 404 }
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404 }
    end
  end
  
  # Redirect to home page with error if user doesn't have permissions for this list
  def verify_permissions_for_list
    unless current_user.lists.include?(@list)
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
  
  def detect_list
    @list = List.lookup_by_id_or_uuid(params[:list_id])
    
    if @list.nil?
      respond_to do |format|
        format.html do
          raise ActiveRecord::RecordNotFound, "Couldn't find List with ID=#{params[:list_id]}"
        end
    
        format.json { render :status => 404, :json => { :message => 'Unable to find list with id requested.'} }
      end
      
      return false
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  def require_user
    unless current_user
      respond_to do |format|
        format.html do
          store_location
          flash[:error] = "You must be logged in to access this page"
          redirect_to new_user_session_url
        end
        
        msg = 'Your access token may be invalid or not yet configured, please try again with valid credentials ' +
              'or contact support@listableapp.com for additional assistance.'

        format.json { render :status => 403, :json => {:message => msg} }
      end

      return false
    else
      # Make sure the update count (used for iPhone "badge") is set to 0 if it isn't 
      # already.
      current_user.reset_update_count
    end
  end

  def require_no_user
    # We allow json requests to go through so that API users can re-check password.
    if current_user
      store_location
      flash[:error] = "You must be logged out to access this page"
      redirect_to account_url
      false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end  
  
  def adjust_format_for_iphone
    if request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(iPhone|iPod)/]
      request.format = :iphone
    end
  end
  
  def detect_user_from_key    
    if params[:key]
      if @user = User.find_by_perishable_token(params[:key])
        UserSession.create(@user)
        return true
      else
        flash[:notice] = "We're sorry, but we couldn't load your account.  Please log in and try again, or contact support@listableapp.com for help."
        redirect_to root_url
      end
    end
  end
  
end
