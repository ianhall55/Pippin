require 'byebug'

class Static

  attr_reader :app

  MIME_TYPES = {
  	'.txt' => 'text/plain',
  	'.jpg' => 'image/jpeg',
  	'.zip' => 'application/zip',
  	'.png' => 'image/png'
  }

  def initialize(app)
  	@app = app
  end

  def call(env)
  	req = Rack::Request.new(env)
  	path = req.path


  	if can_serve?(path)
  		res = begin_serve(path)
  	else
  		res = @app.call(env)
  	end

  	res
  end

  def can_serve?(path)
  	path.index("/public")
  end

  def begin_serve(path)

  	dir = File.dirname(__FILE__)
  	file_name = File.join(dir, '..', path)

  	res = Rack::Response.new
  	if File.exist?(file_name)
  		serve_file(file_name, res)
  	else
  		res.status = 404
  		res.write("File not found")
  	end
  	res
  end

  def serve_file(file_name, res)
  	extension = File.extname(file_name)
  	content_type = MIME_TYPES[extension]
  	file = File.read(file_name)
  	res["Content-Type"] = content_type
  	res.write(file)
  end

end
