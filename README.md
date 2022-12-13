## 笔记：我的Rails + Vue3/React + postgresql 的全栈应用
# 一、常用rails操作
  1、建表 - 建立`postgresql`中的一个`model模型`如User：
  ```rb
    bin/rails g model user email:string name:string
  ```

  2、同步模型的改动到数据库
  ```rb
    bin/rails db:migrate
  ```
  
  3、撤销上次更新操作
  ```rb
    bin/rails db:rollback step=1
  ```

  4、创建某个表如User的`controller`, 可以初始化方法如show、create
  ```rb
    bin/rails g controller users show create
  ```

  5、使用`curl`模拟请求，调试接口
  ```rb
    # post 请求 - 保存用户接口
    curl -X POST http://127.0.0.1:3000/users
    # get 请求，按ID查询接口
    curl http://127.0.0.1:3000/users/1
  ```
  