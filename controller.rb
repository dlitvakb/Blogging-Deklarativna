require_relative 'models.rb'
require_relative 'views.rb'
require 'sinatra/base'

class BlogController < Sinatra::Base
  get '/' do
    (IndexView.new request).render
  end

  get '/about/' do
    (AboutView.new request).render
  end

  get '/posts/' do
    (PostsView.new request, Post.all).render
  end

  get %r{/posts/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/?} do
    date = Date.new params[:year].to_i,
                    params[:month].to_i,
                    params[:day].to_i
    (PostsView.new request, Post.all(:created_at => date)).render
  end

  get '/posts/create/' do
    (PostCreateView.new request).render
  end

  post '/posts/create/' do
    new_post = Post.create(:title=>params['title'], :body=>params['body'])
    new_post.save
    redirect '/posts/'
  end
  
  set :public_folder, File.dirname(__FILE__) + '/media'
end

BlogController.run!
