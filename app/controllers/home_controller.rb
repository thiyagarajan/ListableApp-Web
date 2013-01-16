class HomeController < ApplicationController
  ssl_allowed :show
  
  def index
    unless current_user.nil?
      redirect_to lists_path
    else
      respond_to do |format|
        format.html
        format.iphone
      end
    end
  end
  
  def show
    
    # Some of the pages should be rendered for iPhone if available
    iphone_formatted_pages = %w[ iphone_check_email_confirmation iphone_account_confirmed ]
    
    if iphone_formatted_pages.include?(params[:page])
      respond_to do |format|
        format.html { render :action => params[:page] }
        format.iphone do 
          flash[:notice] = nil
          render :action => params[:page], :layout => 'iphone'
        end
      end
    else
      render :action => params[:page]
    end
    
  end
end
