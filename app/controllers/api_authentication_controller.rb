class ApiAuthenticationController < ApplicationController
  def show
    if User.first(:conditions => {:single_access_token => params[:id]})
      render :status => 200, :json => {:message => 'Authentication succeeded.'}
    else
      render :status => 404, :json => {:message => 'Authentication failed.'}
    end
  end
end
