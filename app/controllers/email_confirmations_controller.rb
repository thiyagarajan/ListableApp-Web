class EmailConfirmationsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => :new
  before_filter :require_no_user
  
  def new
    @user.confirmed = true
    
    if @user.save
      UserSession.create(@user)
      
      respond_to do |format|
        format.html do 
          flash[:notice] = "Welcome to ListableApp.com!  Your email address has been confirmed.  If you have any problems using ListableApp.com please contact us at support@listableapp.com."
          redirect_to lists_path
        end
        
        format.iphone do 
          redirect_to '/iphone_account_confirmed'
        end
      end
      
    else  
      redirect_to '/'
    end
  end  

  private  

  def load_user_using_perishable_token  
    @user = User.find_by_perishable_token(params[:id])  
    
    unless @user  
      flash[:error] = "We're sorry, but we could not locate your account. This may be because your account was already confirmed, so it isn't necessarily an error. Try logging in with your account credentials. If you are still having trouble please contact ListableApp support at support@listableapp.com."
        
      redirect_to root_url
    end
  end
end
