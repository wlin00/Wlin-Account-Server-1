class Api::V1::ValidationCodesController < ApplicationController
  def create
    code = SecureRandom.random_number.to_s[2..7] # 生成一个安全真随机数，本质上是一个小数(0.3213213213...)，转化为字符串，并截取小数点后的1-6位，作为当前随机6位验证码
    validation_code = ValidationCode.new email: params['emial'], kind: 'sign_in', code: code
    if validation_code.save
      p 'res', code
      head 200
    else
      render json: { errors: validation_code.errors }  
    end 
  end
end
