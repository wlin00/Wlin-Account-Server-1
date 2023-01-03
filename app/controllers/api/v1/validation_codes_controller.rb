class Api::V1::ValidationCodesController < ApplicationController
  def create
    # 先判断60秒内是否存在当前和当前输入邮箱一致的登录验证码validation_code对象，若有则返回状态吗429（too many request）来中止发送验证码
    if ValidationCode.exists?(email: params[:email], kind: 'sign_in', created_at: 1.minute.ago..Time.now)
      render json: { message: '当前请求太频繁,请稍后再试' }, status: 429
      return
    end
    # 创建validation_code对象并入库（随后钩子函数里调用Mailer模块发送邮件）
    validation_code = ValidationCode.new email: params[:email], kind: 'sign_in'
    if validation_code.save
      render json: {}, status: 200
    else
      render json: {errors: validation_code.errors}, status: 400
    end
  end
end