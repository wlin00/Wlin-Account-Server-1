class UserMailer < ApplicationMailer
  def welcome_email(code)
    @code = code # 将入参的验证码传给@code，即可展示在html中
    mail(to: "wlin0z@163.com", subject: '请查收您的验证码')
  end
end
