require_relative 'cat'
require_relative '../lib/controller_base'

class CatsController < ControllerBase
  protect_from_forgery

  def index
    @cats = Cat.all
    render :index
  end

  def show
    @cat = Cat.find(params["id"])
    render :show
  end

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

  def new
    @cat = Cat.new
    render :new
  end

end
