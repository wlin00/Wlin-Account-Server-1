class Api::V1::MesController < ApplicationController
  def show # 查询登陆人信息
    # 从jwt中间件中取user_id
    user_id = request.env['current_user_id'] rescue nil
    user = User.find user_id
    return head 404 if user.nil?
    render json: { resource: user }, status: :ok
  end
end
