class Api::V1::SessionsController < ApplicationController
  def create
    # 若当前是测试环境，若验证码code不为 '123456'则return 401
    if Rails.env.test?
      return render status: :unauthorized, json: { errors: '用户名或验证码错误' } if params[:code] != '123456'
    end
    # 若当前非测试环境，需要校验本次会话创建前是否发送验证码
    if !Rails.env.test?
      canSignInFlag = ValidationCodes.exists? email: params[:email], code: params[:code]
      return render status: :unauthorized, json: { errors: '用户名或验证码错误' } unless canSignInFlag
    end
    # 创建会话，校验当前user是否存在于User表中（防止错误删除了User表)
    user = User.find_by_email(params[:email])
    if user.nil?
      return render status: :not_found, json: { errors: '当前用户不存在' }
    end
    # 登陆校验成功，创建响应数据；载荷里放入uid
    # 在rails密钥管理中写入 hmac的密钥 -> hmac_secret: 'wlin$ecretK3y5050'
    payload = { user_id: user.id }
    token = JWT.encode payload, Rails.application.credentials.hmac_secret, 'HS256' # 传入载荷、密钥、加密算法：对称加密Hmac256 来生成jwt加密字符串
    render status: :ok, json: { jwt: token }
  end
end
