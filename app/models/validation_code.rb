class ValidationCode < ApplicationRecord
  validates :email, presence: true
  # validation_code controller/model 代码重构， 和本身数据相关的可以放在model文件的生命周期钩子函数中
  # 定义before_create 钩子， 用于初始化时创建六位随机数
  # 定义after_create 钩子，用于 验证码validation_code 保存（入库）后，调用UserMailer邮件模块发送邮件
  before_create :generate_code
  after_create :send_email
  enum kind: { sign_in: 0, reset_password: 1 } # 定义枚举类型kind，内部的key-value可以被rails读取并进行双向映射
  def generate_code
    self.code = SecureRandom.random_number.to_s[2..7]
  end
  def send_email
    UserMailer.welcome_email(self.email) # 测试直接发送邮件：添加 .deliver!
  end  
end
