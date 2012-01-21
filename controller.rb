require_relative 'service.rb'
require 'sinatra/base'
require 'sinatra'

class Sinatra::Request
  def user
    @user
  end

  def user= user_object
     @user = user_object
  end
end

class BlogController < Sinatra::Base
  enable :sessions

  helpers do
    def _add_user request, user=nil
      session_user = session[:user]
      session_user ||= user

      request.user = session_user
    end

    def require_login request
      _add_user request
      raise if (request.user).nil?
    end
  end

  get '/' do
    _add_user request
    StaticsService.new.index request
  end

  get '/about/' do
    _add_user request
    StaticsService.new.about request
  end

  get '/posts/' do
    _add_user request
    PostsService.new.render_all request
  end

  get '/posts/page/:page/' do |page|
    _add_user request
    PostsService.new.render_for_page request, page.to_i
  end

  get '/posts/:post_id/' do |post_id|
    _add_user request
    PostsService.new.render_by_id request, post_id
  end

  get %r{/posts/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/?} do
    _add_user request
    date = Date.new params[:year].to_i,
                    params[:month].to_i,
                    params[:day].to_i
    PostsService.new.render_by_date request, date
  end

  post '/posts/:post_id/comments/create/' do |post_id|
    begin
      _add_user request
      CommentCreateService.new.create_for post_id,
                                             params['posted_by'],
                                             params['url'],
                                             params['body']
    ensure
      redirect "/posts/#{post_id}/"
    end
  end

  get '/posts/category/:category/' do |category|
    _add_user request
    PostsService.new.render_by_category request, category
  end

  get '/post/create/' do
    require_login request
    PostCreateService.new.create_form request
  end

  post '/post/create/' do
    require_login request
    begin
      PostCreateService.new.create params['title'],
                                      params['body'],
                                      params['categories'].split(',')
    ensure
      redirect '/posts/'
    end
  end

  get '/user/create/' do
    UserCreateService.new.create_form request
  end

  post '/user/create/' do
    begin
      UserCreateService.new.create params['name'],
                                   params['password'],
                                   params['email']
    ensure
      redirect '/user/login/'
    end
  end

  get '/user/login/' do
    UserLoginService.new.create_form request
  end

  get '/user/logout/' do
    request.user = nil
    session[:user] = nil
    redirect '/posts/'
  end

  post '/user/login/' do
    begin
      user = UserLoginService.new.login(
               params['name'],
               params['password']
             )

      session[:user] = user

      _add_user request, user
      redirect '/posts/'
    rescue
      redirect '/user/login/retry/'
    end
  end

  get '/user/login/retry/' do
    UserLoginRetryService.new.create_form request
  end

  set :public_folder, File.dirname(__FILE__) + '/media'
end

BlogController.run!
