class UsernamesController < ApplicationController
  ssl_required :show, :edit, :update unless block_ssl_redirect?
  
  before_filter :require_user
  
  def edit
    respond_to do |format|
      format.html
      format.iphone { render :action => :edit, :layout => 'iphone' }
    end
  end
  
  def update    
    if current_user.update_attributes(params[:user].slice(:login))
      flash[:notice] = "Account updated!"
      redirect_to account_path
    else
      respond_to do |format|
        format.html { render :action => :edit }
        format.iphone { render :action => :edit, :layout => 'iphone' }
      end      
    end
    
  end
  
end
