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

  9、使用 `kaminari` 分页查询demo
  ```rb
    # 查询账单记录
    items = Item.page(params[:page]).per(10) # 分页大小为10
    render json: {
      resource: items,
      pageInfo: {
        pageNo: params[:page],
        pageSize: 10,
        totalCount: Item.count
      }
    }
  ```

  10、安装单元测试框架 `rspec-rails` & 创建`测试环境数据库` 和 `建表`
  ```rb
    # 在Gemfile中
    group :development, :test do
      gem 'rspec-rails', '~> 5.0.0'
    end
    # 然后安装依赖
    bundle install --verbose
    # 然后生成rspec.rb
    bin/rails generate rspec:install
    # 创建测试环境数据库 （先在database.yml) 中完善测试数据库的用户名、pwd、host等信息
    RAILS_ENV=test bin/rails db:create
    # 创建测试环境表，只需要将现有的db/migrate同步测试数据库
    RAILS_ENV=test bin/rails db:migrate
  ```

  11、测试model
  ```rb
    bin/rails generate rspec:model items
  ```

  12、测试controller - 请求测试
  ```rb
    # 测试 账单记录controller
    bin/rails generate rspec:request items
    # 测试 验证码controller
    bin/rails generate rspec:request validation_codes
  ```

  13、执行单测
  ```rb
    bundle exec rspec
  ```

  14、rails借助 `SecureRandom` 生成一个`真随机`的`六位`数字验证码
  ```rb
  code = SecureRandom.random_number.to_s[2..7] # 生成一个安全真随机数，本质上是一个小数(0.3213213213...)，转化为字符串，并截取小数点后的1-6位，作为当前随机6位验证码
  ```