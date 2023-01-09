class Api::V1::TagsController < ApplicationController
  def index # 分页查询标签记录 & 根据请求头中的jwt来筛选出当前用户权限的数据
    # 先获取jwt中间件处理后的《当前用户id》，把它当作查询的where条件之一
    current_user_id = request.env['current_user_id']
    return head 401 unless current_user_id # 若当前查询没有jwt凭证，返回401 unauthorized
    tags = Tag.where({ user_id: current_user_id }).where({ deleted_at: nil })
    tags = tags.where({ kind: params[:kind] }) unless params[:kind].nil?
    tags_page = tags.page(params[:page]).per(10)
    render json: {
      resource: tags_page,
      pager: {
        page: params[:page] || 1,
        per_page: Tag.default_per_page,
        count: tags.count
      }
    }, status: :ok
  end
  def create # 创建
    current_user_id = request.env['current_user_id']
    return head 401 unless current_user_id # 若当前查询没有jwt凭证，返回401 unauthorized
    tag = Tag.new params.permit(:name, :sign, :kind)
    tag.user_id = current_user_id
    if tag.save
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: 422
    end
  end
  def update # 更新
    current_user_id = request.env['current_user_id']
    tag = Tag.find params[:id]
    return head 403 if tag.user_id != current_user_id
    tag.update params.permit(:name, :sign) # 若传了name/sign其一才传参，否则保持当前record的属性与数据库表中一致
    if tag.save
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: 422
    end
  end
  def show # 按id查询Tag表
    current_user_id = request.env['current_user_id']
    tag = Tag.find params[:id]
    return head 403 if tag.user_id != current_user_id # 若查询别人的标签数据返回403
    render json: { resource: tag }
  end
  def destroy # 按id删除Tag表
    current_user_id = request.env['current_user_id']
    tag = Tag.find params[:id]
    return head 403 if tag.user_id != current_user_id
    # 在表中删除tag，实际上是把当前tag的deleted_at更新为Time.now
    tag.deleted_at = Time.now
    if tag.save
      render json: { resource: tag }
    else
      render json: { errors: tag.errors, message: '删除标签失败，请重试' }, status: 422
    end
  end
end
