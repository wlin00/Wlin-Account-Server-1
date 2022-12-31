require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Tags" do
  authentication :basic, :auth
  let(:current_user) { User.create email: '1@qq.com' }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  get "/api/v1/tags" do # 分页查询
    parameter :page, '页码'
    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    example "get tags list" do
      11.times do Tag.create name: 'name', sign: 'sign', user_id: current_user.id end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource'].size).to eq 10
    end
  end
  post "/api/v1/tags" do # 创建
    parameter :name, '名称', required: true
    parameter :sign, '符号', required: true
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    let (:name) { 'x' }
    let (:sign) { 'x' }
    example "create tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
    end
  end
  get "/api/v1/tags/:id" do
    let (:tag) { Tag.create name: 'x', sign:'x', user_id: current_user.id }
    let (:id) { tag.id }
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    example "get tag by id" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['id']).to eq tag.id
    end
  end
  patch "/api/v1/tags/:id" do
    let (:tag) { Tag.create name: 'x', sign:'x', user_id: current_user.id }
    let (:id) { tag.id }
    parameter :name, '名称'
    parameter :sign, '符号'
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    let (:name) { 'y' }
    let (:sign) { 'y' }
    example "update tag by id" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
    end
  end
  delete "/api/v1/tags/:id" do
    let (:tag) { Tag.create name: 'x', sign:'x', user_id: current_user.id }
    let (:id) { tag.id }
    example "delete tag" do
      do_request
      expect(status).to eq 200
    end
  end
end