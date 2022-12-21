require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "index" do
    it "have_http_status_200" do
      get "/"
      expect(response).to have_http_status 200 # 期待请求的响应状态码为200
    end
  end

end
