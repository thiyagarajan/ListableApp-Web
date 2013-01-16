class BulkUpdateController < ApplicationController
  before_filter :require_user

  before_filter :detect_list
  before_filter :verify_permissions_for_list

  skip_before_filter :verify_authenticity_token, :only => :create

  layout nil

  def update
    items = @list.items.all(:conditions => { :id => params[:items] })

    case params[:apply]
      when 'Delete'
        items.each{|i| i.delete}
      when 'Complete'
        items.each{|i| i.update_attributes(:completed => true)}
      when 'Uncomplete'
        items.each{|i| i.update_attributes(:completed => false)}
    end

    head 200
  end
end
