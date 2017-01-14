require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    if req.cookies['_rails_lite_app']
      @cookie = JSON.parse(req.cookies['_rails_lite_app'])
    else
      @cookie = {}
    end

  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    # cookie_attr = {}
    # cookie_attr[:path] = "/"
    # cookie_attr[:value] = @cookie.to_json
    @cookie[:path] = "/"
    res.set_cookie(:_rails_lite_app, @cookie.to_json)
    
  end
end
