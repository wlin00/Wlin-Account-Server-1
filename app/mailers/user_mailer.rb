class UserMailer < ApplicationMailer
  def welcome_email(email) # 发邮件方法 《 welcome_email 》 接受一个string的邮箱
    validation_code = ValidationCode.order(created_at: :desc).find_by_email(email) # 在Validation_code 表中查找最新一条 符合当前邮箱的记录record
    @code = validation_code.code # 将入参的验证码传给@code，即可展示在html中，即在邮件中发送验证码
    mail(to: email, subject: "[#{@code}]请查收您的验证码")
  end
end
