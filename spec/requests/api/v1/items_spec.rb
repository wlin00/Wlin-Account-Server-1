require 'rails_helper'

RSpec.describe "Items", type: :request do
  # 测试《账单记录查询》接口 - 可分页查询 - 可根据请求头的jwt进行用户鉴权，让用户能查询自己的数据
  describe "index" do
    it "(get /api/v1/items) can index by page" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      # 测试分页前，先模拟有两个用户，各自具备11条记录
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag1 = Tag.create name: 'name1', sign: 'sign1', user_id: user1.id
      tag2 = Tag.create name: 'name1', sign: 'sign1', user_id: user2.id
      11.times { Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id, tags_id: [tag1.id], happen_at: '2018-01-01T00:00:00+08:00' } # 两个用户分别创建11条记录，数据库中会有22条
      13.times { Item.create amount: 100, created_at: '2018-01-01', user_id: user2.id, tags_id: [tag2.id], happen_at: '2018-01-01T00:00:00+08:00' }
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
  # 测试《账单记录查询》接口 - 按开始、结束时间范围查询
  describe "index" do
    it "(get /api/v1/items) can index by created_before & created_after" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      user1 = User.create email: '1@qq.com'
      tag1 = Tag.create name: 'name1', sign: 'sign1', user_id: user1.id
      item1 = Item.create amount: 100, created_at: '2022-01-01', user_id: user1.id, tags_id: [tag1.id], happen_at: '2018-01-01T00:00:00+08:00'
      item2 = Item.create amount: 100, created_at: '2022-01-02', user_id: user1.id, tags_id: [tag1.id], happen_at: '2022-01-01T00:00:00+08:00'
      item3 = Item.create amount: 100, created_at: '2022-01-03', user_id: user1.id, tags_id: [tag1.id], happen_at: '2022-01-02T00:00:00+08:00'
      get '/api/v1/items?created_after=2022-01-01&created_before=2022-01-03', headers: user1.generate_auth_header # 按时间范围查询，查询2022-01-01到2022-01-02之间的记录
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resource'].size).to eq 1 # 期望搜出两条：顺序是 [item3]
    end
  end
  # 测试《账单记录查询》接口 - 按开始、结束时间范围查询 - 只传入其中一个查询条件的case
  describe "index" do
    it "(get /api/v1/items) can index by created_before | created_after" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      user1 = User.create email: '1@qq.com'
      tag1 = Tag.create name: 'name1', sign: 'sign1', user_id: user1.id
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id, tags_id: [tag1.id], happen_at: '2018-01-01T00:00:00+08:00'
      item2 = Item.create amount: 100, created_at: '2019-01-01', user_id: user1.id, tags_id: [tag1.id], happen_at: '2018-01-04T00:00:00+08:00'
      get '/api/v1/items?created_after=2018-01-03', headers: user1.generate_auth_header # 按时间范围查询：查询在 2022-01-02 之前的记录
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resource'].size).to eq 1 # 期望搜出两条：顺序是 [item1, item2]
      expect(json['resource'][0]['id']).to eq item2.id
    end
  end
  # 测试《账单记录创建》接口，未登录创建
  describe "create" do
    it "(post /api/v1/items) can not create a record without login" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      user1 = User.create email: '1@qq.com'
      tag1 = Tag.create name: 'name1', sign: 'sign1', user_id: user1.id
      # 数据库是否新增一条数据
      expect {
        post '/api/v1/items', params: { amount: 99, tags_id: [tag1.id], happen_at: '2018-01-01T00:00:00+08:00' }
      }.to change {Item.count}.by 0
      expect(response).to have_http_status 401 # 期待请求的响应状态码为200
    end
  end
  # 测试《账单记录创建》接口，已登录创建
  describe "create" do
    it "(post /api/v1/items) can create a record in login" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      user = User.create email: '1@qq.com'
      tag1 = Tag.create name: 'name1', sign: 'sign1', user_id: user.id
      tag2 = Tag.create name: 'name2', sign: 'sign2', user_id: user.id
      # 数据库是否新增一条数据
      expect {
        post '/api/v1/items', params: { amount: 99, tags_id: [tag1.id, tag2.id], happen_at: '2018-01-01T00:00:00+08:00' }, headers: user.generate_auth_header
      }.to change {Item.count}.by 1
      expect(response).to have_http_status 200 # 期待请求的响应状态码为200
      json = JSON.parse response.body
      expect(json['resource']['amount']).to eq 99 # 测试当前响应的amount字段是否等于传入的值
      expect(json['resource']['user_id']).to eq user.id # 测试当前响应的amount字段是否等于传入的值
      expect(json['resource']['id']).not_to be_nil # 测试当前响应的创建记录的id是否存在（不为空nil）
      expect(json['resource']['happen_at']).to eq '2017-12-31T16:00:00.000Z' # 期望时间符合ISO860标准，并且创建的item记录的时间和入参一致
    end
    it "(post /api/v1/items) has necessar parameters" do
      user = User.create email: '1@qq.com'
      post '/api/v1/items', params: {}, headers: user.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse(response.body)
      expect(json['errors']['amount'][0]).to eq "can't be blank"
      expect(json['errors']['tags_id'][0]).to eq "can't be blank"
      expect(json['errors']['happen_at'][0]).to eq "can't be blank"
    end
  end
  # 测试《账单记录分组查询》接口
  describe "summary" do
    it "(get /api/v1/items/summary) can get items group by happen_at" do
      user = User.create! email: '1@qq.com'
      tag = Tag.create! name: 'name', sign: 'sign', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tags_id: [tag.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tags_id: [tag.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tags_id: [tag.id], happen_at: '2018-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tags_id: [tag.id], happen_at: '2018-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tags_id: [tag.id], happen_at: '2018-06-19T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tags_id: [tag.id], happen_at: '2018-06-19T00:00:00+08:00', user_id: user.id
      get '/api/v1/items/summary', params: {
        happened_after: '2018-01-01',
        happened_before: '2019-01-01',
        kind: 'expenses',
        group_by: 'happen_at'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['happen_at']).to eq '2018-06-18'
      expect(json['groups'][0]['amount']).to eq 200
      expect(json['groups'][1]['happen_at']).to eq '2018-06-19'
      expect(json['groups'][1]['amount']).to eq 300
      expect(json['groups'][2]['happen_at']).to eq '2018-06-20'
      expect(json['groups'][2]['amount']).to eq 300
      expect(json['total']).to eq 800
    end
    it "(get /api/v1/items/summary) can get items group by tag_id" do
      user = User.create! email: '1@qq.com'
      tag1 = Tag.create! name: 'tag1', sign: 'x', user_id: user.id
      tag2 = Tag.create! name: 'tag2', sign: 'x', user_id: user.id
      tag3 = Tag.create! name: 'tag3', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tags_id: [tag1.id, tag2.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tags_id: [tag2.id, tag3.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expenses', tags_id: [tag3.id, tag1.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      get '/api/v1/items/summary', params: {
        happened_after: '2018-01-01',
        happened_before: '2019-01-01',
        kind: 'expenses',
        group_by: 'tag_id'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['tag_id']).to eq tag3.id
      expect(json['groups'][0]['amount']).to eq 500
      expect(json['groups'][1]['tag_id']).to eq tag1.id
      expect(json['groups'][1]['amount']).to eq 400
      expect(json['groups'][2]['tag_id']).to eq tag2.id
      expect(json['groups'][2]['amount']).to eq 300
      expect(json['total']).to eq 600
    end
  end
  # 测试《账单综合overview查询》接口
  describe "overview" do
    it "(get /api/v1/items/overview) can get overview" do
      user = User.create! email: '1@qq.com'
      tag1 = Tag.create! name: 'tag1', sign: 'x', user_id: user.id
      tag2 = Tag.create! name: 'tag2', sign: 'x', user_id: user.id
      tag3 = Tag.create! name: 'tag3', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'income', tags_id: [tag1.id, tag2.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tags_id: [tag2.id, tag3.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 351, kind: 'expenses', tags_id: [tag3.id, tag1.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      get '/api/v1/items/overview', params: {
        happened_after: '2018-01-01',
        happened_before: '2019-01-01',
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['expenses']).to eq "5.51"
      expect(json['income']).to eq "1.00"
      expect(json['profit']).to eq "-4.51"
    end
  end
  # 按Item的id单个查询
  describe 'show' do
    # 测试《单个标签记录查询》接口，未登录
    it '(get /api/v1/items/:id) can not get a record without login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name1', sign: 'sign1', user_id: user.id
      item = Item.create amount: 100, created_at: '2018-01-01', user_id: user.id, tags_id: [tag.id], happen_at: '2018-01-01T00:00:00+08:00'
      get "/api/v1/items/#{item.id}"
      expect(response).to have_http_status 401
    end
    # 测试《单个标签记录查询》接口，已登录
    it '(get /api/v1/items/:id) can get a record in login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name1', sign: 'sign1', user_id: user.id
      item = Item.create amount: 100, created_at: '2018-01-01', user_id: user.id, tags_id: [tag.id], happen_at: '2018-01-01T00:00:00+08:00'
      get "/api/v1/items/#{item.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq item.id
    end
    # 测试《单个标签记录查询》接口，登录后查询别人的账单
    it '(get /api/v1/items/:id) can not get a recrod of other people' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag1 = Tag.create name: 'name', sign: 'sign', user_id: user1.id
      tag2 = Tag.create name: 'name', sign: 'sign', user_id: user2.id
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id, tags_id: [tag1.id], happen_at: '2018-01-01T00:00:00+08:00'
      item2 = Item.create amount: 100, created_at: '2018-01-01', user_id: user2.id, tags_id: [tag2.id], happen_at: '2018-01-01T00:00:00+08:00'
      get "/api/v1/items/#{item2.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status 403
    end
  end
  # 更新账单
  describe 'update' do
    # 测试《标签记录更新》接口，未登录
    it '(patch /api/v1/items/:id) can not update a record without login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name1', sign: 'sign1', user_id: user.id
      item = Item.create amount: 100, created_at: '2018-01-01', user_id: user.id, tags_id: [tag.id], happen_at: '2018-01-01T00:00:00+08:00'
      patch "/api/v1/items/#{item.id}", params: {name: 'y', sign: 'y'}
      expect(response).to have_http_status(401)
    end
    # 测试《标签记录更新》接口，已登录
    it '(patch /api/v1/items/:id) can update a record in login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name1', sign: 'sign1', user_id: user.id
      tag_new = Tag.create name: 'name2', sign: 'sign2', user_id: user.id
      item = Item.create amount: 100, created_at: '2018-01-01', user_id: user.id, tags_id: [tag.id], happen_at: '2018-01-01T00:00:00+08:00'
      patch "/api/v1/items/#{item.id}", params: {amount: 101, tags_id: [tag_new.id], happen_at: '2018-01-01T00:00:00+08:01', kind: 'income'}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['amount']).to eq 101
      expect(json['resource']['tags_id'][0]).to eq tag_new.id
      expect(json['resource']['kind']).to eq 'income'
    end
    # 测试《标签记录更新》接口，已登录 & 只更新部分属性
    it '(patch /api/v1/items/:id) can update only part of a record in login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name1', sign: 'sign1', user_id: user.id
      item = Item.create amount: 100, created_at: '2018-01-01', user_id: user.id, tags_id: [tag.id], happen_at: '2018-01-01T00:00:00+08:00'
      patch "/api/v1/items/#{item.id}", params: {amount: 101}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['amount']).to eq 101
      expect(json['resource']['tags_id'][0]).to eq tag.id
    end
    # 测试《标签记录更新》接口，登录后更新别人的标签
    it '(patch /api/v1/items/:id) can get a record in login' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag1 = Tag.create name: 'name1', sign: 'sign1', user_id: user1.id
      tag2 = Tag.create name: 'name2', sign: 'sign2', user_id: user2.id
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id, tags_id: [tag1.id], happen_at: '2018-01-01T00:00:00+08:00'
      item2 = Item.create amount: 100, created_at: '2018-01-01', user_id: user2.id, tags_id: [tag2.id], happen_at: '2018-01-01T00:00:00+08:00'
      patch "/api/v1/items/#{item2.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status 403
    end
  end
  # 测试《单个账单记录删除》接口
  describe "destory" do
    # 测试《单个账单记录删除》接口，未登录
    it '(delete /api/v1/items/:id) can not delete a reord without login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name1', sign: 'sign1', user_id: user.id
      item = Item.create amount: 100, created_at: '2018-01-01', user_id: user.id, tags_id: [tag.id], happen_at: '2018-01-01T00:00:00+08:00'
      delete "/api/v1/items/#{tag.id}"
      expect(response).to have_http_status 401
    end
    # 测试《单个标签记录删除》接口，已登录
    it '(delete /api/v1/items/:id) can delete a record in login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name1', sign: 'sign1', user_id: user.id
      item = Item.create amount: 100, created_at: '2018-01-01', user_id: user.id, tags_id: [tag.id], happen_at: '2018-01-01T00:00:00+08:00'
      delete "/api/v1/items/#{item.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq item.id
      item.reload
      expect(item.deleted_at).not_to be_nil # 希望已经被删除的账单记录，deleted_at字段非空
    end
  end
end
