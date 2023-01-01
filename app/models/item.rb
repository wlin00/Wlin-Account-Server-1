class Item < ApplicationRecord
  enum kind: { expenses: 1, income: 2 }
  validates :amount, presence: true
  validates :kind, presence: true
  validates :happen_at, presence: true
  validates :tags_id, presence: true
  # 自定义校验 - 验证当前传入的tags_id数组需要被包含在当前用户的全量标签数组中
  validate :check_tags_id_belong_to_user
  def check_tags_id_belong_to_user
    # 获取当前用户的全量tag_ids
    total_tag_ids = Tag.where({ user_id: self.user_id }).map(&:id)
    if self.tags_id & total_tag_ids != self.tags_id
      self.errors.add :tags_id, '标签不属于当前用户'
    end
  end
end
