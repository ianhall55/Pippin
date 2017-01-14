require 'rack'
require_relative '../lib/controller_base.rb'
require_relative '../lib/router'
require_relative '../lib/sql_object'
# To test out your CSRF protection, go to the new cat form and
# make sure it works! Alter the form_authenticity_token and see that
# your server throws an error.

class Cat < SQLObject
  attr_reader :name, :owner

end

class CatsController < ControllerBase
  protect_from_forgery

  def create
    @cat = Cat.new(params["cat"])
    if @cat.save
      flash[:notice] = "Saved cat successfully"
      redirect_to "/cats"
    else
      flash.now[:errors] = @cat.errors
      render :new
    end
  end

  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def show
    @cat = Cat.find(params["id"])
    render :show
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  post Regexp.new("^/cats$"), CatsController, :create
  get Regexp.new("^/owners$"), CatsController, :index
  get Regexp.new("^/owners/new$"), CatsController, :new
  get Regexp.new("^/owners/(?<id>\\d+)$"), CatsController, :show
  post Regexp.new("^/owners$"), CatsController, :create
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new

  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)
