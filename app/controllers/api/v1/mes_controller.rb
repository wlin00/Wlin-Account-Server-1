class Api::V1::MesController < ApplicationController
  def show # 查询登陆人信息
    # header = request.headers['Authorization']
    # jwt = header.split(' ')[1] rescue ''
    # payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' } rescue nil # decode jwt
    # return head 400 if payload.nil?
    # user_id = payload[0]['user_id'] rescue nil

    # 从jwt中间件中取user_id
    user_id = request.env['current_user_id'] rescue nil
    user = User.find user_id
    return head 404 if user.nil?
    render json: { resource: user }, status: :ok
  end
end
