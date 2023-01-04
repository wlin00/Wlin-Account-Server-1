class User < ApplicationRecord
  validates :email, presence: true
  # 登录校验成功，创建响应数据；载荷里放入uid
  # 在rails密钥管理中写入 hmac的密钥 -> hmac_secret: 'wlin$ecretK3y5050'
  def generate_jwt # 加密 user_id 换取 jwt & payload里加入《exp》配置，可以定义jwt过期时间
    payload = { user_id: self.id, exp: (Time.now + 2.hours).to_i } # 定义jwt过期时间为2小时
    JWT.encode payload, Rails.application.credentials.hmac_secret, 'HS256'
  end
  def generate_auth_header # 根据用户id - 换取jwt凭证（经过密钥+HS256对称加密算法处理）- 再转换成用于请求头部的json格式
    return { "Authorization": "Bearer #{self.generate_jwt}" }
  end
end
