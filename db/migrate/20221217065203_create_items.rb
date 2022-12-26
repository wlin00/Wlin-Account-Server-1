class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.bigint :user_id # 当前账单记录所关联的用户user_id
      t.integer :amount
      t.text :note
      t.bigint :tags_id, array: true # 账单记录里的tag数组
      t.datetime :happen_at

      t.timestamps
    end
  end
end
