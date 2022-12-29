require 'rails_helper'

RSpec.describe "Mes", type: :request do
  describe "show" do
    it "(get /api/v1/me) can get user info" do # 期望有User账号后，能进行会话登陆，登陆后状态码200 & 响应体中有key为jwt & value为string的字段
      user = User.create email: 'wlin0z@163.com'
      post '/api/v1/session', params: { email: 'wlin0z@163.com', code: '123456' } # 模拟发送登陆（创建会话）请求
      json = JSON.parse response.body
      jwt = json['jwt']
      # 模拟登陆（创建会话）后，可以通过/api/v1/me （请求头的Authorization字段设置好jwt）查询到个人信息
      get '/api/v1/me', headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resource']['id']).to eq user.id
    end
  end
end
