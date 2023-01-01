require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "ValidationCodes" do
  post "/api/v1/validation_codes" do
    parameter :email, type: :string, required: true
    let(:email) { 'wlin0z@163.com' }
    example "send validation code" do
      # expect(UserMailer).to receive(:welcome_email).with(email) # 单元测试 - 验证码生成后会调用Mailer模块发送邮件
      # do_request
      # expect(status).to eq 200
      # expect(JSON.parse(response_body)['code']).to be_nil # 期望响应体里不返回验证码，而是要让用户去邮箱里查收validation code
    end
  end
end