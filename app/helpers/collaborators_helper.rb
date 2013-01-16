module CollaboratorsHelper
  
  # Displays an icon to delete this item
  def delete_collaborator_box(collaborator)
    link_to(image_tag("garbage.png",
                      :alt    => "Remove this collaborator from list",
                      :height => 30,
                      :width  => 30), list_collaborator_path(collaborator.list, collaborator),
            :method => :delete,
            :confirm => "Are you sure you wish to remove this collaborator from the list?",
            :class => 'delete_button')
  end
  
  def render_email(collaborator)
    <<-EOS
      <div class="collaborator_login">
        #{collaborator.user.login} #{@list.creator == collaborator.user ? '(Creator)' : ''}
      </div>
    EOS
  end
  
  def invitation_login_message
    <<-EOS
      We need to make sure that you're the intended recipient of this list, so before you can see it 
      you'll have to #{link_to('create a free account', new_user_path)} on listableapp.com or 
      #{link_to('log in to your existing account', new_user_session_path)} if you have one.
    EOS
  end
  
end
