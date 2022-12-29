require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  # 测试创建验证码 validation_code 接口
  describe "create" do
    it "(post /api/v1/validation_codes) can create a record" do
      post '/api/v1/validation_codes', params: { email: 'wlin0z@163.com' }
      expect(response).to have_http_status(200) # 期待请求的响应状态码为200
    end
  end
  # 测试发送太频繁会返回429（60秒内）
  describe "create" do 
    it "(post /api/v1/validation_codes) can only be sent once in sixty seconds" do
      post '/api/v1/validation_codes', params: { email: 'wlin0z@163.com' }
      expect(response).to have_http_status(200) # 期待请求的响应状态码为200
      post '/api/v1/validation_codes', params: { email: 'wlin0z@163.com' }
      expect(response).to have_http_status(429) # 期待频繁请求的响应状态码为429
    end
  end
end
