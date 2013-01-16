class ListOrderController < ApplicationController
  before_filter :require_user
  
  before_filter :detect_list
  before_filter :verify_permissions_for_list

  def create
    @list.items.active.each do |itm|
      if new_position = params["items"].index(itm.id.to_s)
        
        itm.position = new_position + 1
        itm.save
      else 
        
        # Something is missing in the input array.  Make sure list stays packed by 
        # moving this item to the bottom of the list.  In the future make sure this happens
        # less frequently by updating the web page when another user makes changes to 
        # the list.
        itm.move_to_bottom
      end

    end
    
    head 200
  end

end
