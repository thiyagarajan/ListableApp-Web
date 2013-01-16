module ItemsHelper
  def unsubscribe_text_for(list)
    if list.users.count > 1
      "Are you sure you wish to unsubscribe from this list?  You will no longer be able to access its contents, nor will you receive updates about it after unsubscribing."
    else
      "Are you sure you wish to unsubscribe from this list?  You are the only user subscribed, so it will be deleted once you unsubscribe."
    end
  end
end