class AutoJwt # AutoJwt 中间件：自动解密请求头中的jwt，并将其payload中的userId存放于request.env['current_user_id']
  def initialize(app) # 初始化
    @app = app
  end
  def call(env) # 当中间件被调用时（routes之后，controller 之前），会执行call钩子
    # 先获取请求头
    header = env['HTTP_AUTHORIZATION']
    jwt = header.split(' ')[1] rescue ''
    payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' } rescue nil
    env['current_user_id'] = payload[0]['user_id'] rescue nil # 之前controller中的请求头会带上jwt解密后的user_id，可以方便取用
    @status, @header, @response = @app.call(env) # @app.call 执行后续controller
    return [@status, @header, @response] # 获取后续controller请求的status、响应头、响应体
  end 
end