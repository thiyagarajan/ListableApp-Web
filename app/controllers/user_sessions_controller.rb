class UserSessionsController < ApplicationController
  ssl_allowed :destroy
  
  before_filter :require_no_user, :only => :new
  before_filter :require_user, :only => :destroy

  skip_before_filter :verify_authenticity_token, :only => :create
  
  def new
    @user_session = UserSession.new
    
    respond_to do |format|
      format.html
      format.iphone { render :action => :new, :layout => 'iphone' }
    end    
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save
      
      respond_to do |format|      
        format.html do
          redirect_to lists_path
          logger.info("Login successful for #{params[:user_session][:login]}")
        end

        format.json do 
          render :status => 200, :json => { 
            :token  => current_user.single_access_token,
            :user_id => current_user.id
          }
        end
        
        format.iphone do
          redirect_to lists_path
          logger.info("Login successful for #{params[:user_session][:login]}")
        end
        
      end
    
    else
    
      respond_to do |format|
        format.html do
          flash[:error] = "Login failed, please check your username and password and try again"
          logger.info("Login failed for #{params[:user_session][:login]}")
          redirect_to new_user_session_path
        end

        format.iphone do
          flash[:error] = "Login failed"
          logger.info("Login failed for #{params[:user_session][:login]}")
          redirect_to new_user_session_path          
        end

        format.json { render :status => 404, :json => {:message => 'Authentication failed'} }
      end
      
    end
  end
  
  # HTML-only action, since API use is based on the single access token.
  def destroy
    current_user_session.destroy
    redirect_to '/'
  end

end
