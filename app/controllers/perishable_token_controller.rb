class PerishableTokenController < ApplicationController
  
  before_filter :require_user

  def show
    current_user.reset_perishable_token!

    respond_to do |format|
      format.json do 
        render :status => 200, :json => {
          :token  => current_user.perishable_token
        }
      end
    end
  end
  
end
