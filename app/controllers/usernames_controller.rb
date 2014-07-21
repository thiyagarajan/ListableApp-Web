class UsernamesController < ApplicationController
  #ssl_required :show, :edit, :update unless block_ssl_redirect?
  
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

  def firstname_edit
    respond_to do |format|
      format.html
    end
  end
  
  def firstname_update
    if current_user.update_attributes(params[:user].slice(:first_name))
      flash[:notice] = "FirstName updated!"
      redirect_to account_path
    else
      respond_to do |format|
        format.html { render :action => :firstname_edit }
      end
    end
  end

  def lastname_edit
    respond_to do |format|
      format.html
    end
  end

  def lastname_update
    if current_user.update_attributes(params[:user].slice(:last_name))
      flash[:notice] = "LastName updated!"
      redirect_to account_path
    else
      respond_to do |format|
        format.html { render :action => :lastname_edit }
      end
    end
  end
  
  def initials_edit
    respond_to do |format|
      format.html
    end
  end

  def initials_update
    if current_user.update_attributes(params[:user].slice(:initials))
      flash[:notice] = "Initials are updated successfully!"
      redirect_to account_path
    else
      respond_to do |format|
        format.html { render :action => :initials_edit }
      end
    end
  end

  def phone_number_edit
    respond_to do |format|
      format.html
    end
  end

  def phone_number_update
    if current_user.update_attributes(params[:user].slice(:phone_number))
      flash[:notice] = "Initials are updated successfully!"
      redirect_to account_path
    else
      respond_to do |format|
        format.html { render :action => :initials_edit }
      end
    end
  end

end

