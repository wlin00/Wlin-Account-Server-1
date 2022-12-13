class User < ApplicationRecord
  # 给user表添加必传校验 - email 必填
  validates :email, presence: true
end
