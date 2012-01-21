require_relative 'service.rb'
require 'sinatra/base'

class BlogController < Sinatra::Base
  enable :sessions
  helpers do
    def _add_user request
      user = session[:user]
      request.instance_variable_set("@user", user) if !user.nil?
    end

    def require_login
      raise if session[:user].nil?
    end
  end

  get '/' do
    StaticsService.new.index request
  end

  get '/about/' do
    StaticsService.new.about request
  end

  get '/posts/' do
    PostsService.new.render_all request
  end

  get '/posts/page/:page/' do |page|
    PostsService.new.render_for_page request, page.to_i
  end

  get '/posts/:post_id/' do |post_id|
    PostsService.new.render_by_id request, post_id
  end

  get %r{/posts/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/?} do
    date = Date.new params[:year].to_i,
                    params[:month].to_i,
                    params[:day].to_i
    PostsService.new.render_by_date request, date
  end

  post '/posts/:post_id/comments/create/' do |post_id|
    begin
      CommentCreateService.new.create_for post_id,
                                             params['posted_by'],
                                             params['url'],
                                             params['body']
    ensure
      redirect "/posts/#{post_id}/"
    end
  end

  get '/posts/category/:category/' do |category|
    PostsService.new.render_by_category request, category
  end

  get '/post/create/' do
    require_login
    PostCreateService.new.create_form request
  end

  post '/post/create/' do
    require_login
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

  post '/user/login/' do
    begin
      session[:user] = UserLoginService.new.login params['user'],
                                                  params['passord']
      _add_user request
    rescue
      redirect '/user/retry/'
    end
  end

  set :public_folder, File.dirname(__FILE__) + '/media'
end

BlogController.run!
