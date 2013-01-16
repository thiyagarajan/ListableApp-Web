class DeviceTokenController < ApplicationController
  before_filter :require_user
  
  def update
    
    if current_user.update_attributes(:device_token => params[:device_token], :device_registered_at => DateTime.now)
      
      # Once we set the device ID for this user, we nullify all of the other occurrences of this device id
      # in the database.  This prevents previous users on a particular device from getting notifications when the
      # app user on the device has changed.
      User.update_all("device_token = NULL", ["device_token = ? AND NOT id = ?", params[:device_token], current_user.id])
      
      respond_to do |format|
        format.json { render :status => 200, :json => { :message => '' } }
      end
      
    else
      respond_to do |format|
        format.json { render :status => 400, :json => {:message => 'Failed to update device token'} }
      end
      
    end
    
  end
  
end
