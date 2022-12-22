## 笔记：我的Rails + Vue3/React + postgresql 的全栈应用

# 一、环境配置
  1、初始化数据库,在mac环境，执行下面代码初始化创建数据库，以`db-for-mangosteen`为主键key，并且关联到网络`network1`
  ```rb
    docker run -d      --name db-for-mangosteen      -e POSTGRES_USER=mangosteen      -e POSTGRES_PASSWORD=123456      -e POSTGRES_DB=mangosteen_dev      -e PGDATA=/var/lib/postgresql/data/pgdata      -v mangosteen-data:/var/lib/postgresql/data      --network=network1      postgres:14
  ```

# 二、部署配置
  1、持久化云服务器远程连接的`超时时长`：
    命令行输入 `vi /etc/ssh/sshd_config`，然后找到 `ClientAliveInterval` 修改为300，表示最大超时时长为5分钟, 找到 `ClientAliveCountMax` 修改为5，表示最大连接数为5

  2、ubuntu安装`docker`， `root` 用户权限下
  ```ts
    (1) 进入网站：https://docs.docker.com/engine/install/ubuntu/
    (2) 云服务器更新apt-get: apt-get update
    (3) 安装其他依赖：
      apt-get install \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
    (4) Add Docker’s `official GPG key`:
      mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    (5) 开启 `docker` 仓库 :
      echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    (6) 安装docker:
      apt-get update  
      apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    (7) 验证docker安装成功
      docker --version
      docker run hello-world
  ```

  3、为当前项目和docker添加一个专属用户，而非一直使用`root`，方便后续开发：
  ```ts
    (1) adduser mangosteen, 创建一个专属用户 mangosteen 及其分组，
    (2) 将mongosteen用户添加到docker组： usermod -a -G docker mangosteen
    (3) 然后将root的 ~/.ssh/authroized_keys, 复制到mangosteen用户的home/.ssh目录, 并且将复制文件的权限交接给mangosteen用户：
      - 先进入 /home/mangosteen 创建.ssh文件夹，cd /home/mangosteen | mkdir .ssh
      - 然后进行文件拷贝：cp ~/.ssh/authroized_keys /home/mangosteen/.ssh
      - 文件交接，在/home/mangosteen目录下，交接.ssh权限给mangosteen：chown -R mangosteen:mangosteen .ssh
  ```

  4、使用 `docker` 部署思路 
  `后端部署`步骤
  ```ts
    (1) 云服务器准备一个新用户
    (2) 云服务器上安装docker
    (3) 上传本地的Dockerfile 和 源代码
    (4) 用Dockerfile构建运行环境
    (5) 在运行环境里运行源代码
    (6) 用 Nginx 做转发
  ```
  `后端版本更新`步骤
  ```ts
    (1) 上传新Dockerfile
    (2) 上传新的源代码
    (3) 用Dockerfile构建运行环境
    (4) 在新的运行环境里运行新的源代码
    (5) 用 Nginx 做转发
  ```
  `前端部署`步骤
  ```ts
    (1) 将静态资源上传CDN，代码中引用路径也改为cdn地址
    (2) 将项目打包上传到云服务器的nginx/html目录，并进行反向代理和gzip压缩等，需要分流考虑负载均衡
  ```

  5、部署当前应用到 `宿主机（mac）`步骤
  ```ts
    (1) 增加 pack_for_host.sh、setup_host.sh、host.Dockerfile等文件
    (2) 更改 pack_for_host.sh 执行权限： chmod +x bin/pack_for_host.sh
    (3) 执行 pack_for_host.sh 来将应用源代码打包至宿主环境
  ```

  6、执行代码 - 宿主机部署
  ```ts
    // （1）linux里打包源代码到宿主环境
    sh bin/pack_for_host.sh
    // （2）宿主机VsCode运行setup_host.sh 并传递DB_HOST、DB_PASSWORD、RAILS_MASTER_KEY 来启动外部容器并构建dockerFile的《生产环境》
    DB_HOST=db-for-mangosteen DB_PASSWORD=123456 RAILS_MASTER_KEY=2617e5cf2af9fc0108db38b42b470b80 mangosteen_deploy/setup_host.sh
    // （3）创建生产环境数据库
    docker exec -it mangosteen-prod-1 bin/rails db:create db:migrate
    // （4）宿主机部署的 host.DockerFile，用于构建docker镜像
    FROM ruby:3.0.0
    ENV RAILS_ENV production
    RUN mkdir /mangosteen
    RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
    WORKDIR /mangosteen
    ADD mangosteen-*.tar.gz ./
    RUN bundle config set --local without 'development test'
    RUN bundle install
    ENTRYPOINT bundle exec puma
  ```

  7、执行代码 - 自动化云服务器部署
  ```sh
    # （1）linux里打包源代码到云服务器（scp -> ssh cp），然后在云服务器构建 Dockerfile出生产环境，并写入生产环境密钥
    sh bin/pack_for_remote.sh

    # （2）pack_for_remote.sh, 解析
    # 注意修改 user 和 ip
    user=mangosteen # 写好环境变量：ssh用户名、ip地址
    ip=47.94.212.148
    time=$(date +'%Y%m%d-%H%M%S')
    dist=tmp/mangosteen-$time.tar.gz
    current_dir=$(dirname $0)
    deploy_dir=/home/$user/deploys/$time
    gemfile=$current_dir/../Gemfile
    gemfile_lock=$current_dir/../Gemfile.lock
    vendor_cache_dir=$current_dir/../vendor/cache
    function title { # log 函数
      echo 
      echo "###############################################################################"
      echo "## $1"
      echo "###############################################################################" 
      echo 
    }
    yes | rm tmp/mangosteen-*.tar.gz;  # 删除之前的源代码压缩包
    title '打包源代码为压缩文件'
    bundle cache
    tar --exclude="tmp/cache/*" -czv -f $dist * # 压缩源代码为tar文件，可被docker构建时的ADD命令解压缩
    title '创建远程目录'
    ssh $user@$ip "mkdir -p $deploy_dir/vendor"
    title '上传压缩文件'
    scp $dist $user@$ip:$deploy_dir/ # ssh cp
    scp $gemfile $user@$ip:$deploy_dir/
    scp $gemfile_lock $user@$ip:$deploy_dir/
    scp -r $vendor_cache_dir $user@$ip:$deploy_dir/vendor/
    title '上传 Dockerfile'
    scp $current_dir/../config/host.Dockerfile $user@$ip:$deploy_dir/Dockerfile # 核心文件上传
    title '上传 setup 脚本'
    scp $current_dir/setup_remote.sh $user@$ip:$deploy_dir/
    title '上传版本号'
    ssh $user@$ip "echo $time > $deploy_dir/version"
    title '执行远程脚本'
    ssh $user@$ip "export version=$time; /bin/bash $deploy_dir/setup_remote.sh" # 跑完pack_for_remote.sh 继续跑setup_remote.sh 来构建docker，然后在开发环境执行源代码 以及初始化/更新数据库

    # （3）setup_remote.sh, 解析
    # 环境变量初始化
    user=mangosteen
    root=/home/$user/deploys/$version
    container_name=mangosteen-prod-1
    db_container_name=db-for-mangosteen-production
    DB_HOST=db-for-mangosteen-production
    RAILS_MASTER_KEY=2617e5cf2af9fc0108db38b42b470b80
    DB_PASSWORD=123456
    function set_env { # 可供输入参数
      name=$1
      while [ -z "${!name}" ]; do
        echo "> 请输入 $name:"
        read $name
        sed -i "1s/^/export $name=${!name}\n/" ~/.bashrc
        echo "${name} 已保存至 ~/.bashrc"
      done
    }
    function title { # log function
      echo 
      echo "###############################################################################"
      echo "## $1"
      echo "###############################################################################" 
      echo 
    }
    title '创建数据库'
    if [ "$(docker ps -aq -f name=^${DB_HOST}$)" ]; then
      echo '已存在数据库'
    else # 创建数据库
      docker run -d --name $DB_HOST \
                --network=network2 \
                -e POSTGRES_USER=mangosteen \
                -e POSTGRES_DB=mangosteen_production \
                -e POSTGRES_PASSWORD=$DB_PASSWORD \
                -e PGDATA=/var/lib/postgresql/data/pgdata \
                -v mangosteen-data:/var/lib/postgresql/data \
                postgres:14
      echo '创建成功'
    fi
    title 'docker build'
    docker build $root -t mangosteen:$version  # 构建docker镜像
    if [ "$(docker ps -aq -f name=^mangosteen-prod-1$)" ]; then
      title 'docker rm'
      docker rm -f $container_name
    fi
    title 'docker run'
    docker run -d -p 3000:3000 \ # docker运行
              --network=network2 \ 
              --name=$container_name \
              -e DB_HOST=$DB_HOST \
              -e DB_PASSWORD=$DB_PASSWORD \
              -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
              mangosteen:$version

    echo
    echo "是否要更新数据库？[y/N]"
    read ans
    case $ans in # 生产环境数据库同步
        y|Y|1  )  echo "yes"; title '更新数据库'; docker exec $container_name bin/rails db:create db:migrate ;;
        n|N|2  )  echo "no" ;;
        ""     )  echo "no" ;;
    esac

    title '全部执行完毕'

    # （4）云服务器部署的 host.DockerFile，用于docker build
    FROM ruby:3.0.0
    ENV RAILS_ENV production
    RUN mkdir /mangosteen
    RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
    WORKDIR /mangosteen
    ADD Gemfile /mangosteen
    ADD Gemfile.lock /mangosteen
    ADD vendor/cache /mangosteen/vendor/cache
    RUN bundle config set --local without 'development test'
    RUN bundle install --local
    ADD mangosteen-*.tar.gz ./
    ENTRYPOINT bundle exec puma
  ```


# 三、rails 密钥管理 - 开发环境和生产环节各有一个128位的密钥用于对称加密，来让应用具备安全性
  1、创建开发环境的master.key密钥，rails会对应创建加密好后的密文.enc，并复制放在临时文件中的密钥 `secret_key_base`
  ```ts
    // 创建开发环境密钥 & 密文，来获取开发环境权限
    rm config/credentials.yml.enc
    EDITOR="code --wait" bin/rails credentials:edit 
  ```
  2、创建生产环境密钥key，然后将复制的开发环境密钥替换给当前密钥
  ```ts
    EDITOR="code --wait" bin/rails credentials:edit --environment production
  ```
  3、重新生成一次开发环境密钥
  ```ts
    EDITOR="code --wait" bin/rails credentials:edit 
  ```
  4、如何查看开发/生产环境的密钥：
  ```rb
    # （1）打开开发环境的控制台
    bin/rails console
    # 使用开发环境的密钥，查看开发环境密文（获取所有加密信息的明文）
    Rails.application.credentials.config

    # （2）打开生产环境的控制台
    RAILS_ENV=production bin/rails console
    # 使用生产环境的密钥，查看生产环境密文（获取所有加密信息的明文）
    Rails.application.credentials.config
  ```

# 四、常用rails操作
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

  15、云服务器
