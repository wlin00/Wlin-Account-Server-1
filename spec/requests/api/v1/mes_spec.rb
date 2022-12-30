require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe "Mes", type: :request do
  include ActiveSupport::Testing::TimeHelpers # 引入时间方法，可以使用 travel_to Time.now - 3.hours & travel_back 来定义一个时间范围代码块
  # 测试《个人信息查询》接口，具备用户身份的查询
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
  # 测试《个人信息查询》接口，jwt过期， 无法使用需要身份鉴权的接口
  describe "show " do
    it "(get /api/v1/me) can not use if jwt expired" do # 期望当jwt凭证过期时，无法使用需要身份鉴权相关的接口如 /api/v1/me用户信息查询接口
      travel_to Time.now - 3.hours
      user = User.create email: 'wlin0z@163.com'
      jwt = user.generate_jwt
      travel_back # 3小时的时间代码块，后面的代码执行时间在3小时之后
      get '/api/v1/me', headers: { "Authorization": "Bearer #{jwt}" }
      expect(response).to have_http_status 401
    end
  end
  # 测试《个人信息查询》接口，jwt未过期， 可以使用需要身份鉴权的接口
  describe "show " do
    it "(get /api/v1/me) can use if jwt unexpired" do # 期望当jwt凭证没有过期时，可以使用需要身份鉴权相关的接口如 /api/v1/me用户信息查询接口
      travel_to Time.now - 1.hours
      user = User.create email: 'wlin0z@163.com'
      jwt = user.generate_jwt
      travel_back # 1小时的时间代码块，后面的代码执行时间在1小时之后
      get '/api/v1/me', headers: { "Authorization": "Bearer #{jwt}" }
      expect(response).to have_http_status 200
    end
  end
end
