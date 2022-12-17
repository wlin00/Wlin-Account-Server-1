require 'rails_helper'

# Rspec.describe 参数1:当前描述的对象；参数2:测试代码块
RSpec.describe User, type: :model do 
  it '有 email' do # 描述当前创建的User对象有email字段
    user = User.new email: 'wlin0z@163.com'
    expect(user.email).to eq 'wlin0z@163.com' # to eq不区分对象内存地址，而 to be是需要完全相等
  end  
end
