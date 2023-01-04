class AutoJwt # AutoJwt 中间件：自动解密请求头中的jwt，并将其payload中的userId存放于request.env['current_user_id']
  def initialize(app) # 初始化
    @app = app
  end
  def call(env) # 当中间件被调用时（routes之后，controller 之前），会执行call钩子
    # jwt检测 跳过以下不需要登录态的接口
    return @app.call(env) if ['/', '/api/v1/session','/api/v1/validation_codes'].include? env['PATH_INFO']
    # 获取请求头，解密jwt获取其信息，获取当前登录用户id，并存放在当前request.env中
    header = env['HTTP_AUTHORIZATION']
    jwt = header.split(' ')[1] rescue ''
    begin
      payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' }
    rescue JWT::ExpiredSignature
      return [401, {}, [JSON.generate({reason: 'token expired', message: '当前登录已过期,请重新登录'})]] # 401 status case1：jwt 过期
    rescue
      return [401, {}, [JSON.generate({reason: 'token invalid', message: '当前未登录，请先登录'})]] # 401 status case1：jwt 无效（可能被篡改）
    end
    env['current_user_id'] = payload[0]['user_id'] rescue nil # 之前controller中的请求头会带上jwt解密后的user_id，可以方便取用
    @status, @header, @response = @app.call(env) # @app.call 执行后续controller
    return [@status, @header, @response] # 获取后续controller请求的status、响应头、响应体
  end 
end