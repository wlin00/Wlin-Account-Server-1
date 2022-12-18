require 'rails_helper'

RSpec.describe "Items", type: :request do
  # 测试账单记录分页查询接口
  describe "show" do
    it "can index by page" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      # 测试分页前，先模拟创建11条记录
      11.times { Item.create amount: 100 }
      expect(Item.count).to eq 11
      # 测分页，第一页为10条
      get '/api/v1/items?page=1'
      expect(response).to have_http_status 200 # 期待请求的响应状态码为200
      json = JSON.parse response.body
      expect(json['resource'].size).to eq 10 # 测试相应的数据的resource字段长度为10（size表示相应数据的长度，count一般表示当前数据库里的某个表的数据量）
      # 测试第二页，是否1条数据
      get '/api/v1/items?page=2'
      json = JSON.parse response.body
      expect(json['resource'].size).to eq 1
    end
  end
  # 测试账单记录创建接口
  describe "create" do
    it "can create a record" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      # 数据库是否新增一条数据
      expect {
        post '/api/v1/items', params: { amount: 99 }
      }.to change {Item.count}.by 1
      expect(response).to have_http_status 200 # 期待请求的响应状态码为200
      json = JSON.parse response.body
      expect(json['resource']['amount']).to eq 99 # 测试当前响应的amount字段是否等于传入的值
      expect(json['resource']['id']).not_to be_nil # 测试当前响应的创建记录的id是否存在（不为空nil）
    end
  end
end
