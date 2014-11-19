class UserNotifier < ActionMailer::Base
  default from: "robot-LRRY@unlockgate.today"
  
  def send_forgot_password_email(user)
    @user = user
    mail(to: @user.email,
         subject: "Reset your password")
  end
end
