class Api::V1::TagsController < ApplicationController
  def show # 分页查询标签记录 & 根据请求头中的jwt来筛选出当前用户权限的数据
    # 先获取jwt中间件处理后的《当前用户id》，把它当作查询的where条件之一
    current_user_id = request.env['current_user_id']
    return head 401 unless current_user_id # 若当前查询没有jwt凭证，返回401 unauthorized
    tags = Tag.where({ user_id: current_user_id })
      .page(params[:page]).per(10)
    render json: {
      resource: tags,
      pager: {
        page: params[:page] || 1,
        per_page: Tag.default_per_page,
        count: Tag.count
      }
    }, status: :ok
  end
  def create # 创建
    current_user_id = request.env['current_user_id']
    return head 401 unless current_user_id # 若当前查询没有jwt凭证，返回401 unauthorized
    tag = Tag.new sign: params[:sign], name: params[:name], user_id: current_user_id
    if tag.save
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: 422
    end
  end
end
