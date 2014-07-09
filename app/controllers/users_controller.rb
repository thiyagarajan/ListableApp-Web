class UsersController < ApplicationController
  #ssl_required :show, :edit, :update unless block_ssl_redirect?
  
  before_filter :require_no_user, :only => [:new, :create]
  
  before_filter :detect_user_from_key, :only => :show
  before_filter :require_user, :only => [:show, :edit, :update]

  skip_before_filter :verify_authenticity_token, :only => :create  

  def new
    @user = User.new
    
    respond_to do |format|
      format.html
      format.iphone { render :action => :new, :layout => 'iphone' }
    end
    
  end
  
  # Create user if no account with this email exists.  Also allow for cases where user
  # account was created by another user during an invitation.  Once an account is confirmed,
  # user is not allowed to use this action to change password.
  def create
    
    if @user = User.find_by_email(params[:user][:email], :conditions => ['confirmed = false AND creator_id IS NOT NULL'])
      
      # User was already in system, created by another user and not confirmed.  Allow them to change password, login and opts.
      @user.attributes = @user.attributes.merge(params[:user].slice(:login, :password, :password_confirmation, :accept_promo_emails))
      
    else 
      
      # just normal new user construction from params
      @user = User.new(params[:user])
    end
    
    if @user.save_without_session_maintenance
      
      flash[:notice] = "Account registered, please check your email for a confirmation message."
      
      @user.deliver_email_confirmation!
    
      respond_to do |format|
        format.html   { redirect_to root_url }
        format.iphone { redirect_to '/iphone_check_email_confirmation' }
      end
      
    else
      respond_to do |format|
        format.html   { render :action => :new }
        format.iphone { render :action => :new, :layout => 'iphone' }
      end
    end
  end
  
  def show
    @user = @current_user
    
    respond_to do |format|
      format.html
      format.iphone { render :action => :show, :layout => 'iphone' }
    end
  end
 
  def edit
    @user = @current_user
    
    respond_to do |format|
      format.html
      format.iphone { render :action => :edit, :layout => 'iphone' }
    end
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
end
