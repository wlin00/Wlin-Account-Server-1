require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  # 测试《创建验证码》接口，能正常返回200
  describe "create" do
    it "(post /api/v1/validation_codes) can create a record" do
      post '/api/v1/validation_codes', params: { email: 'wlin0z@163.com' }
      expect(response).to have_http_status(200) # 期待请求的响应状态码为200
    end
  end
  # 测试《创建验证码》接口，发送太频繁会返回429（60秒内）
  describe "create" do 
    it "(post /api/v1/validation_codes) can only be sent once in sixty seconds" do
      post '/api/v1/validation_codes', params: { email: 'wlin0z@163.com' }
      expect(response).to have_http_status(200) # 期待请求的响应状态码为200
      post '/api/v1/validation_codes', params: { email: 'wlin0z@163.com' }
      expect(response).to have_http_status(429) # 期待频繁请求的响应状态码为429
    end
  end
  # 测试《创建验证码》接口，邮箱如果不合法会返回422
  describe "create" do 
    it "(post /api/v1/validation_codes) needs promissory email" do
      post '/api/v1/validation_codes', params: { email: 'wlin0z' }
      expect(response).to have_http_status(422) # 期待请求的响应状态码为200
      json = JSON.parse response.body
      expect(json['errors']['email'][0]).to eq('当前参数格式有误,请修改')
    end
  end
end
