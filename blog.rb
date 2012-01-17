require_relative 'controller.rb'
require 'sinatra/base'

class Blog < Sinatra::Base
  get '/' do
    StaticsController.new.index request
  end

  get '/about/' do
    StaticsController.new.about request
  end

  get '/posts/' do
    PostsController.new.render_all request
  end

  get '/posts/page/:page/' do |page|
    PostsController.new.render_for_page request, page.to_i
  end

  get '/posts/:post_id/' do |post_id|
    PostsController.new.render_by_id request, post_id
  end

  get %r{/posts/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/?} do
    date = Date.new params[:year].to_i,
                    params[:month].to_i,
                    params[:day].to_i
    PostsController.new.render_by_date request, date
  end

  post '/posts/:post_id/comments/create/' do |post_id|
    begin
      PostsController.new.create_comment_for post_id,
                                             params['posted_by'],
                                             params['url'],
                                             params['body']
    ensure
      redirect "/posts/#{post_id}/"
    end
  end

  get '/posts/category/:category/' do |category|
    PostsController.new.render_by_category request, category
  end

  get '/post/create/' do
    PostsController.new.create_post_form request
  end

  post '/post/create/' do
    begin
      PostsController.new.create_post params['title'],
                                      params['body'],
                                      params['categories'].split(',') 
    ensure
      redirect '/posts/'
    end
  end

  set :public_folder, File.dirname(__FILE__) + '/media'
end

Blog.run!
