class CommentMailer < ActionMailer::Base
  
  def mail(user, event, comment)
    @recipients  = "info@demowatch.eu"
    @from        = "#{user.email}"
    @subject     = "[www.demowatch.eu] new Comment"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:comment] = comment
    @body[:event] = event
    @body[:url]   = 'www.demowatch.de'
  end  

end
