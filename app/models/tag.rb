class Tag < ApplicationRecord
  enum kind: { expenses: 1, income: 2 }
  belongs_to :user
  validates :name, presence: true
  validates :sign, presence: true
  validates :kind, presence: true
  validates :name, length: { maximum: 5 } # 校验标签名最大长度为5个字符
  validates :kind, presence: true
end
