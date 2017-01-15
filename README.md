# Pippin

Pippin is a web application development framework written in Ruby, inspired by Rails.  The framework includes a controller base, a router, flash and session cookies, and middleware that display exceptions and serve static files similar to rails.  It also includes Object Relational Modeling similar to ORM that maps to a relational database (sqlite is used in demo).

The below setup up is for an app included in the bin folder that demonstrates how the framework can be set up and used.

## App Setup

This app is built using a simple proc that listens for and responds to requests. It also includes the middleware to serve static files and display exceptions.

```ruby
require 'rack'
require_relative '../lib/show_exceptions'
require_relative '../lib/static'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new

  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  use Static
  run app
end.to_app

Rack::Server.start(
 app: app,
 Port: 3000
)
```

## Router Setup

The router is used to create RESTful routes using standard HTTP verbs to instantiate and call methods on your controllers.  This is done by requiring the lib/router file and instantiating the router.  Then call the draw method on the router instance and pass in a proc containing routes you want your app to respond to.  The arguments are the HTTP method, the regular expression the route will match, the controller to be instantiated, and the CRUD method to be called on it.  After writing the router and router.draw method, include the router in the app proc as shown above, with Rack Request and Response objects as inputs.

```ruby
require_relative '../lib/router'

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  post Regexp.new("^/cats$"), CatsController, :create
end
```

## ORM Setup

The ORM setup is simple. require the lib/sql_object file.  Then have each class inherit from the SQLObject class.  The class name should be the same name as the database table.  If it is not, use the table_name assignment method.  This will give you similar functionality to the Active Record ORM.  You can use the belongs_to, has_many, and has_one_through associations.  Also include various methods that allow you to interact with the underlying database.

```ruby
require_relative '../lib/sql_object'

class Cat < SQLObject
  belongs_to :owner

end

class Owner < SQLObject
	belongs_to :house
  has_many :cats

end

class House < SQLObject
	has_many :owners

end
```

## Controller Setup

To setup up your controller, require the lib/controller_base file then have your controller class inherit from the ControllerBase class.  Then create methods to respond to various router requests.

```ruby
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
```

## View Setup

To set up views, modify the views folder.  Create folders named after the corresponding controller it will serve views to.  Then create view files and reference them in the render method of the controller. The below example has a cats_controller folder for the CatsController.  The only views supported so far are html, erb templates.  

![views](./readme_photos/views.png)

You can pass data to the views by creating instance variables in the controller methods.  These instance variables will be available in the view template and can be interpolated into the view using ERB templating demonstrated in the sample index view below.

```html
<h1>ALL THE CATS</h1>

<% if flash[:notice] %>
  Notice: <%= flash[:notice] %>
<% end %>

<pre>Cat Data: </pre>
<ul>
  <% @cats.each do |cat| %>
    <li>
      <h3>ID: <%= cat.id %></h3>
      <h3>Name: <%= cat.name %></h3>
      <h3>Owner ID: <%= cat.owner_id %></h3>
    </li>
  <% end %>

</ul>
<a href="/cats/new">New Cat!</a>
```

## Static files

Static files you want to serve through your app, whether images or css files, should be placed in the public file.  

![static_files](./readme_photos/static_files.png)
