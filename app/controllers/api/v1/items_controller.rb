class Api::V1::ItemsController < ApplicationController
  def show # 分页查询账单记录 & 加入时间范围查询参数
    items = Item.where({ created_at: params[:created_after]..params[:created_before] }).page(params[:page]).per(10)
    render json: { 
      resource: items, pager: {
        page: params[:page] || 1,
        per_page: Item.default_per_page, # pageSize
        count: Item.count
      }
    }, status: 200 # 可修改返回状态码
  end
  def create # 创建账单记录
    item = Item.new amount: params[:amount]
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }  
    end  
  end
  def getFirstItem # 获取第一条账单
    item = Item.page(1).per(1)
    render json: { 
      resource: item
    }, status: 200 # 可修改返回状态码
  end  
end
