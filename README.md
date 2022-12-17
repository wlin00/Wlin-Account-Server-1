## 笔记：我的Rails + Vue3/React + postgresql 的全栈应用
# 一、常用rails操作
  1、建表 - 建立`postgresql`中的一个`model模型`如User，执行后会生成两个文件：
    一是：class构造函数`user.rb` ，可用于定义一些字段约束，如`email字段必填校验`等；
    二是：用于直接修改数据库的`migrate`文件 `create_users.rb`，可以在此定义主键，或增加`长度limit`等校验
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

  4、创建某个表如User的`controller`, 可以初始化方法如show、create， 具体的`api逻辑`在此实现
  ```rb
    bin/rails g controller users show create
  ```
  若要创建 `嵌套路由` 中的controller，则是执行：
  ```rb
    bin/rails g controller items Api::V1::Items # 注意路径 + 控制器名都要首字母大写
  ```

  5、使用`curl`模拟请求，调试接口
  ```rb
    # post 请求 - 保存用户接口
    curl -X POST http://127.0.0.1:3000/users # 可选择添加 -v 来查看http 状态码
    # get 请求，按ID查询接口
    curl http://127.0.0.1:3000/users/1
    # post 路由中调用
    curl -X POST http://127.0.0.1:3000/api/v1/items  
  ```
  
  6、mac环境重启 `db`
  ```rb
    docker start db-for-mangosteen
  ```

  7、加速bundle instal, 切换到ruby-china镜像
  ```rb
   bundle config mirror.https://rubygems.org https://gems.ruby-china.com
  ```

  8、全局配置kaminari
  ```rb
    bin/rails g kaminari:config
  ```