class Api::V1::SessionsController < ApplicationController
  def create
    # 若当前是测试环境，若验证码code不为 '123456'则return 401
    if Rails.env.test?
      return render status: :unauthorized, json: { message: '用户名或验证码错误' } if params[:code] != '123456'
    end
    # 若当前非测试环境，需要校验本次会话创建前是否发送验证码
    if !Rails.env.test?
      canSignInFlag = ValidationCode.exists? email: params[:email], code: params[:code], used_at: nil # 确保数据库中有一条未使用过的验证码
      return render status: :unauthorized, json: { message: '用户名或验证码错误' } unless canSignInFlag
    end
    # 创建会话，若当前user是否存在于User表中，则查询到当user，否则创建新的user（使用rails的 User.find_or_create_by 方法来创建或查询）
    user = User.find_or_create_by email: params[:email]
    render status: :ok, json: { jwt: user.generate_jwt } # generate_jwt 会抽离到user model中
  end
end
