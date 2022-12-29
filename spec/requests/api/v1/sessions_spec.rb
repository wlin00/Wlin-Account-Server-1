require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "create" do
    it "(get /api/v1/sessions) can create a jwt" do # 期望有User账号后，能进行会话登陆，登陆后状态码200 & 响应体中有key为jwt & value为string的字段
      User.create email: 'wlin0z@163.com'
      post '/api/v1/session', params: { email: 'wlin0z@163.com', code: '123456' } # 模拟发送登陆（创建会话）请求
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['jwt']).to be_a(String) # 期望响应体的jwt字段是个string，若期望jwt为null可以写成 .to be_nil
    end
  end
end
