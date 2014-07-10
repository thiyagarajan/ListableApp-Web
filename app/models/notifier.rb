class Notifier < ActionMailer::Base
  def new_invitation_notification(creator, created_user, list)
    default_url_options[:host] = SERVER_HOST

    recipients created_user.email
    from "ListableApp Support <support@listableapp.com>"
    subject "#{creator.login} shared the list \"#{list.name}\" with you"
    body :created_user => created_user, :list => list, :creator => creator
  end

  def email_confirmation(user)
    default_url_options[:host] = SERVER_HOST

    subject "ListableApp.com Email Confirmation"
    from "ListableApp Support <support@listableapp.com>"
    recipients user.email
    body :email_confirmation_url => "http://listablebeta.ondemandworld.com/email_confirmations/#{user.perishable_token}", :email => user.email
  end

  def password_reset_instructions(user)
    default_url_options[:host] = SERVER_HOST

    subject "Password Reset Instructions"
    from "ListableApp Support <support@listableapp.com>"
    recipients user.email
    body :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
