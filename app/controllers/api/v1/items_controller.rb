class Api::V1::ItemsController < ApplicationController
  def show # 分页查询账单记录 & 加入时间范围查询参数 & 根据请求头中的jwt来筛选出当前用户权限的数据
    # 先获取jwt中间件处理后的《当前用户id》, 把它当作查询的where条件之一
    current_user_id = request.env['current_user_id'] rescue nil
    return head 401 unless current_user_id # 若当前查询没有jwt凭证，表示无权限，返回401 unauthorized
    items = Item.where({ user_id: current_user_id })
      .where({ created_at: params[:created_after]..params[:created_before] })
      .page(params[:page]).per(10)
    render json: { 
      resource: items, pager: {
        page: params[:page] || 1,
        per_page: Item.default_per_page, # pageSize
        count: Item.count
      }
    }, status: 200 # 可修改返回状态码
  end
  def create # 创建账单记录
    current_user_id = request.env['current_user_id'] rescue nil
    return head 401 unless current_user_id # 若当前查询没有jwt凭证，表示无权限，返回401 unauthorized
    item = Item.new amount: params[:amount], user_id: current_user_id
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: 422  
    end  
  end
  def getFirstItem # 获取第一条账单
    current_user_id = request.env['current_user_id'] rescue nil
    return head 401 unless current_user_id # 若当前查询没有jwt凭证，表示无权限，返回401 unauthorized
    item = Item.page(1).per(1)
    render json: { 
      resource: item
    }, status: 200 # 可修改返回状态码
  end  
end
