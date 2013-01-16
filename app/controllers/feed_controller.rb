class FeedController < ApplicationController
  before_filter :require_user
  
  include ActionView::Helpers::DateHelper

  def show
    
    blips = Blip.for_user(current_user).map do |b|      
      nb = {
        :user_image           => Digest::MD5.hexdigest(b.originating_user.email),
        :message              => message_for(b),
        :time_ago             => time_ago_in_words(b.created_at)
      }
      
      unless b.list.nil?
        nb[:list] = {
          :id   => b.list.id,
          :name => b.list.name
        }
      end
      
      nb
    end
    
    respond_to do |format|
      format.json do
        render :json => blips
      end
      
    end
  end
  
  private
  
  def message_for(blip)
    user_name = blip.originating_user == current_user ? "you" : blip.originating_user.login
    list_name = blip.list.nil? ? "a deleted list" : blip.list.name
    "'#{blip.affected_entity_name}' was #{blip.action_type.past_term} by #{user_name} on #{list_name}."
  end
end