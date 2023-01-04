require 'rails_helper'

RSpec.describe "Tags", type: :request do
  # 测试《标签记录查询》接口 - 已登录 & 可分页查询 - 可根据请求头的jwt进行用户鉴权，让用户能查询自己的数据
  describe "index" do
    it "(get /api/v1/tags) can index by page" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      # 测试分页前，先模拟有两个用户，各自具备标签记录
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      11.times { Tag.create name: 'name1', sign: 'sign1', user_id: user1.id } # 两个用户分别创建记录，数据库中总记录数会有24条
      13.times { Tag.create name: 'name2', sign: 'sign2', user_id: user2.id }
      expect(Tag.count).to eq 24
      # 测用户1的分页，第一页为10条，第二页1条
      get '/api/v1/tags?page=1', headers: user1.generate_auth_header
      expect(response).to have_http_status 200 # 期待请求的响应状态码为200
      json = JSON.parse response.body
      expect(json['resource'].size).to eq 10 # 测试相应的数据的resource字段长度为10（size表示相应数据的长度，count一般表示当前数据库里的某个表的数据量）
      # 测试第二页，是否1条数据
      get '/api/v1/tags?page=2', headers: user1.generate_auth_header
      json = JSON.parse response.body
      expect(json['resource'].size).to eq 1
    end
  end
  # 测试《标签记录创建》接口，未登录
  describe "create" do
    it "(post /api/v1/tags) can not create a record without login" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      user1 = User.create email: '1@qq.com'
      # 数据库是否新增一条数据
      expect {
        post '/api/v1/tags', params: { name: 'name1', sign: 'sign1' }
      }.to change {Tag.count}.by 0
      expect(response).to have_http_status 401 # 期待请求的响应状态码为200
    end
  end
  # 测试《标签记录创建》接口，已登录
  describe "create" do
    it "(post /api/v1/tags) can create a record in login" do # 用 describe 描述本次用例要测试的内容（每次新的describe会清空测试数据库的数据）
      user1 = User.create email: '1@qq.com'
      # 数据库是否新增一条数据
      expect {
        post '/api/v1/tags', params: { name: 'name1', sign: 'sign1' }, headers: user1.generate_auth_header
      }.to change {Tag.count}.by 1
      expect(response).to have_http_status 200 # 期待请求的响应状态码为200
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'name1' # 测试当前响应的amount字段是否等于传入的值
      expect(json['resource']['sign']).to eq 'sign1' # 测试当前响应的amount字段是否等于传入的值
      expect(json['resource']['id']).not_to be_nil # 测试当前响应的创建记录的id是否存在（不为空nil）
    end
  end
  # 更新
  describe 'update' do
    # 测试《标签记录更新》接口，未登录
    it '(patch /api/v1/tags/:id) can not update a record without login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: {name: 'y', sign: 'y'}
      expect(response).to have_http_status(401)
    end
    # 测试《标签记录更新》接口，已登录
    it '(patch /api/v1/tags/:id) can update a record in login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: {name: 'y', sign: 'y'}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'y'
      expect(json['resource']['sign']).to eq 'y'
    end
    # 测试《标签记录更新》接口，已登录 & 只更新部分属性
    it '(patch /api/v1/tags/:id) can update only part of a record in login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: {name: 'y'}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'y'
      expect(json['resource']['sign']).to eq 'x'
    end
    # 测试《标签记录更新》接口，登录后更新别人的标签
      it '(patch /api/v1/tags/:id) can get a record in login' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag = Tag.create name: 'name', sign: 'sign', user_id: user2.id
      patch "/api/v1/tags/#{tag.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status 403
    end
  end
  # 按Tag的id单个查询
  describe 'show' do
    # 测试《单个标签记录查询》接口，未登录
    it '(patch /api/v1/tags/:id) can not get a record without login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name', sign: 'sign', user_id: user.id
      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status 401
    end
    # 测试《单个标签记录查询》接口，已登录
    it '(get /api/v1/tags/:id) can get a record in login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name', sign: 'sign', user_id: user.id
      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq tag.id
    end
    # 测试《单个标签记录查询》接口，登录后查询别人的标签
    it '(get /api/v1/tags/:id) can not update a recrod of other people' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag = Tag.create name: 'name', sign: 'sign', user_id: user2.id
      get "/api/v1/tags/#{tag.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status 403
    end
  end
  describe 'destroy'
    # 测试《单个标签记录删除》接口，未登录
    it '(delete /api/v1/tags/:id) can not delete a record without login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name', sign: 'sign', user_id: user.id
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status 401
    end
    # 测试《单个标签记录删除》接口，已登录
    it '(delete /api/v1/tags/:id) can delete a record in login' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: 'name', sign: 'sign', user_id: user.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq tag.id
      tag.reload
      expect(tag.deleted_at).not_to be_nil # 希望已经被删除的标签记录，deleted_at字段非空
    end
    # 测试《单个标签记录删除》接口，登录后删除别人的标签
    it '(delete /api/v1/tags/:id) can not delete a recrod of other people' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag = Tag.create name: 'name', sign: 'sign', user_id: user2.id
      delete "/api/v1/tags/#{tag.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status 403
    end
  end

