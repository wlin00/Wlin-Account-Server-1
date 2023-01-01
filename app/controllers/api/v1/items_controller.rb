class Api::V1::ItemsController < ApplicationController
  def index # 分页查询账单记录 & 加入时间范围查询参数 & 根据请求头中的jwt来筛选出当前用户权限的数据
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
    item = Item.new params.permit(:amount, :happen_at, tags_id: []) # 简便写法：从入参中提取必传字段
    item.user_id = current_user_id
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
  def summary
    hash = Hash.new
    items = Item
      .where(user_id: request.env['current_user_id'])
      .where(kind: params[:kind])
      .where(happen_at: params[:happened_after]..params[:happened_before])
    items.each do |item|  
      # 区分当前是按什么维度对数据进行分组，group_by可能为：1、happen_at 创建时间; 2、tag_id 标签id
      if params[:group_by] == 'happen_at'
        key = item.happen_at.in_time_zone('Beijing').strftime('%F') # 将入参的happen_at ISO860格式的时间转化为北京时间
        hash[key] ||= 0
        hash[key] += item.amount # 转换为 { '2018-01-01': 300, '2019-03-02': 100 } 的map格式
      else
        # 遍历每条账单的tags_id数组，汇总数据到map
        item.tags_id.each do |tag_id|
          key = tag_id
          hash[key] ||= 0
          hash[key] += item.amount # 转换成 { '1': 300, '2': 100 }
        end
      end
    end
    # 收集获取hash后，遍历hash，得到最终分组聚合后的groups数据
    groups = hash
      .map { |key, value| {"#{params[:group_by]}": key, amount: value} }
    # 排序时，区分当前分组维度来排序
    if params[:group_by] == 'happen_at'  
      groups.sort! { |a, b| a[:happen_at] <=> b[:happen_at] } # 对当前happen_at字段进行升序排序
    elsif params[:group_by] == 'tag_id'
      groups.sort! { |a, b| b[:amount] <=> a[:amount] } # 对当前金额amount字段进行降序排序
    end
    render json: {
      groups: groups,
      total: items.sum(:amount)
    }  
  end
end
