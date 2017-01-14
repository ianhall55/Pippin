require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
require 'byebug'


class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params={})
    @req = req
    @res = res
    @params = req.params.merge(route_params)

    @@protect_from_forgery ||= false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'Already built response' if already_built_response?
    @res.header['location'] = url
    @res.status = 302
    session.store_session(@res)

    flash.store_flash(@res)

    @already_built_response = true
    nil
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Already built response" if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    session.store_session(@res)
    flash.store_flash(@res)
    @already_built_response = true
    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    f = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    html = ERB.new(f).result(binding)
    render_content(html, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if @@protect_from_forgery && @req.env["REQUEST_METHOD"] != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end 

    self.send(name.to_sym)
    render(name) unless already_built_response?
  end

  def form_authenticity_token
    @form_token ||= SecureRandom.urlsafe_base64(16)
    @res.set_cookie('authenticity_token', value: @form_token, path: '/')
    @form_token
  end

  def check_authenticity_token
    auth_cookie = @req.cookies['authenticity_token']
    unless auth_cookie && auth_cookie == params['authenticity_token']
      raise "Invalid authenticity token"
    end
  end 

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end 

end
