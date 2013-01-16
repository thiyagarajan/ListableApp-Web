class UserListOrderController < ApplicationController
  before_filter :require_user
  
  def create
    current_user.user_list_links.each do | lnk |
      lnk.position = params["movable-user-list"].index(lnk.id.to_s) + 1
      lnk.save
    end
          
    head 200
  end

end
