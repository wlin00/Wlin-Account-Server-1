class Api::V1::ItemsController < ApplicationController
  # def show # 测试按id查询
  #   item = Item.find_by_id params[:id]
  #   if item
  #     render json: { resource: item } 
  #   else
  #     render json: { resource: false }
  #   end    
  # end
  def show # 分页查询账单记录
    items = Item.page(params[:page]).per(10)
    render json: { 
      resource: items, pager: {
        page: params[:page] || '1',
        per_page: '100', # pageSize
        count: Item.count
      }
    }
  end
  def create # 创建账单记录
    item = Item.new amount: 1
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }  
    end  
  end
end
