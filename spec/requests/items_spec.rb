require 'rails_helper'

RSpec.describe "Items", type: :request do
  # 测试账单记录查询接口 - 可分页查询 - 可根据请求头的jwt进行用户鉴权，让用户能查询自己的数据
  describe "show" do
    it "(get /api/v1/items) can index by page" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      # 测试分页前，先模拟有两个用户，各自具备11条记录
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      11.times { Item.create amount: 100, user_id: user1.id } # 两个用户分别创建11条记录，数据库中会有22条
      13.times { Item.create amount: 100, user_id: user2.id }
      expect(Item.count).to eq 24
      # 测用户1的分页，第一页为10条，第二页1条
      get '/api/v1/items?page=1', headers: user1.generate_auth_header
      expect(response).to have_http_status 200 # 期待请求的响应状态码为200
      json = JSON.parse response.body
      expect(json['resource'].size).to eq 10 # 测试相应的数据的resource字段长度为10（size表示相应数据的长度，count一般表示当前数据库里的某个表的数据量）
      # 测试第二页，是否1条数据
      get '/api/v1/items?page=2', headers: user1.generate_auth_header
      json = JSON.parse response.body
      expect(json['resource'].size).to eq 1
    end
  end
  # 测试账单记录查询接口 - 按开始、结束时间范围查询
  describe "show" do
    it "(get /api/v1/items) can index by created_before & created_after" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      user1 = User.create email: '1@qq.com'
      item1 = Item.create amount: 100, created_at: '2022-01-01', user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2022-01-02', user_id: user1.id
      item3 = Item.create amount: 100, created_at: '2022-01-03', user_id: user1.id
      get '/api/v1/items?created_after=2022-01-01&created_before=2022-01-02', headers: user1.generate_auth_header # 按时间范围查询，查询2022-01-01到2022-01-02之间的记录
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resource'].size).to eq 2 # 期望搜出两条：顺序是 [item1, item2]
      expect(json['resource'][0]['id']).to eq item1.id
      expect(json['resource'][1]['id']).to eq item2.id
    end
  end
  # 测试账单记录查询接口 - 按开始、结束时间范围查询 - 只传入其中一个查询条件的case
  describe "show" do
    it "(get /api/v1/items) can index by created_before | created_after" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      user1 = User.create email: '1@qq.com'
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2019-01-01', user_id: user1.id
      get '/api/v1/items?created_after=2018-01-03', headers: user1.generate_auth_header # 按时间范围查询：查询在 2022-01-02 之前的记录
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resource'].size).to eq 1 # 期望搜出两条：顺序是 [item1, item2]
      expect(json['resource'][0]['id']).to eq item2.id
    end
  end
  # 测试账单记录创建接口
  describe "create" do
    it "(post /api/v1/items) can create a record" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
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
