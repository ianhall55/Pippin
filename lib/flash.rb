require 'json'

class Flash

  attr_reader :flash_hash
  attr_accessor :now

  def initialize(req)
    # @req = req
    #
    # @flash_hash = @req.cookies['_rails_lite_app_flash']
    #
    #   @flash_hash = JSON.parse(req.cookies['_rails_lite_app_flash'])
    #   # @req.cookies.delete('_rails_lite_app_flash')
    # else
    #   @flash_hash = {}
    # end
    # @now = {}

    cookie = req.cookies['_rails_lite_app_flash']
    cookie_content = cookie ? JSON.parse(cookie) : {}
    @now = FlashStore.new(cookie_content)
    @flash_hash = FlashStore.new

  end



  def []=(key,val)
    @flash_hash[key] = val
    @now = val
  end

  def [](key)
    @flash_hash[key] || @now[key]
  end

  def store_flash(res)
    # cookie_attr = {}
    # cookie_attr[:path] = "/"
    # cookie_attr[:value] = @flash_hash.to_json

    res.set_cookie('_rails_lite_app_flash', value: @flash_hash.to_json, path: '/')

  end

end

class FlashStore
  def initialize(store = {})
    @store = store
  end

  def [](key)
    @store[key.to_s]
  end

  def []=(key, val)
    @store[key.to_s] = val
  end

  def to_json
    @store.to_json
  end
end
