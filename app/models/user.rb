class User < ApplicationRecord
  validates :email, presence: true
  def generate_jwt # 加密 user_id 换取 jwt
    payload = { user_id: self.id }
    JWT.encode payload, Rails.application.credentials.hmac_secret, 'HS256'
  end
  def generate_auth_header # 根据用户id - 换取jwt凭证（经过密钥+HS256对称加密算法处理）- 再转换成用于请求头部的json格式
    return { Authorization: "Bearer #{self.generate_jwt}" }
  end
end
