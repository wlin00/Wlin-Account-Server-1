require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "create" do
    it "can create a record" do
      post '/api/v1/validation_codes', params: { email: 'wlin0z@163.com' }
      expect(response).to have_http_status(200) # 期待请求的响应状态码为200
    end
  end
end
