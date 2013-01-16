class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user
  
  def new
    respond_to do |format|
      format.html
      format.iphone { render :layout => 'iphone' }
    end
  end
  
  def create
    @user = User.find_by_email(params[:email])
    
    if @user
      if @user.confirmed?
        @user.deliver_password_reset_instructions!
      
        flash[:notice] = "Instructions to reset your password have been emailed to you. " +
          "Please check your email."
        
        redirect_to root_url
      else
        @user.deliver_email_confirmation!

        flash[:error] = "Your account must be confirmed by email before you can log in.  We just re-sent a confirmation email in case you didn't receive the first.  If you can't find it, please check your spam folder."
        
        respond_to do |format|
          format.html   { redirect_to root_url }
          format.iphone { redirect_to '/iphone_check_email_confirmation' }
        end
      end
    else
      
      flash[:notice] = "No user was found with that email address"
      render :action => :new
    end
  end
  
  def edit
    respond_to do |format|
      format.html
      format.iphone { render :layout => 'iphone' }
    end
  end
 
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password successfully updated"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
 
  private
  
  def load_user_using_perishable_token
    @user = User.find_by_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account." +
        "If you are having issues try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
      redirect_to root_url
    end
  end
end
