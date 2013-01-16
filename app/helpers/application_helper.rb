# Methods added to this helper will be available to all templates in the application.
require 'ostruct'

module ApplicationHelper

  def page_header_links
    login_state_link, account_link = if current_user
      [ link_to("Log out", user_session_path, :method => :delete, :confirm => "Are you sure you want to log out?"),
        link_to("My Account", account_path) ]
    else
      [ link_to("Log in", new_user_session_path),
        link_to("Create account", new_account_path) ]
    end

    unless request.format == :iphone
      [ link_to('FAQ', '/faq'),
        account_link,
        login_state_link
      ].join("&nbsp;|&nbsp;")
    end
  end

  def gravatar_url_for(email)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end
  
  def render_blip(blip)
    # Build a reasonable empty object for modified_item if it's nil
    modified_item = blip.modified_item.nil? ? OpenStruct.new(:name => "A deleted item", :email => "Deleted email", :list => nil) : blip.modified_item

    # The user may have been deleted, and in that case we insert an empty string for the gravatar
    gravatar = !blip.originating_user.nil? ? 
      image_tag(gravatar_url_for(blip.originating_user.email), { :width => 80, :height => 80, :class => 'gravatar-image' }) :
      ""    

    list_name = blip.list.nil? ? "a recently deleted list" : link_to(blip.list.name, list_items_path(:list_id => blip.list.id))
    user_name = if blip.originating_user == @current_user 
        "you"
      elsif blip.originating_user.nil?
        "an unknown user"
      else
        blip.originating_user.login
      end
    
    <<-EOS
      #{gravatar}
      <div class='stream-text'>
        <p class='stream-message'>
        '#{blip.affected_entity_name}' was #{blip.action_type.past_term} by 
        #{user_name}
        on #{list_name}.
        </p>
      
        <p class='stream-date'>
          #{time_ago_in_words(blip.created_at)} ago 
        </p>
      </div>
    EOS
  end
end
