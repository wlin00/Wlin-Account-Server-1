require 'rails_helper'

RSpec.describe "Tags", type: :request do
  # 测试《标签记录查询》接口 - 可分页查询 - 可根据请求头的jwt进行用户鉴权，让用户能查询自己的数据
  describe "show" do
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
end
