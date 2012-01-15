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
    (PostsView.new request, Post.all(:order=>[:created_at.desc])).render
  end

  get %r{/posts/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/?} do
    date = Date.new params[:year].to_i,
                    params[:month].to_i,
                    params[:day].to_i
    (PostsView.new request, Post.all(
                              :created_at.gt=>date.to_s,
                              :created_at.lt=>(date + 1).to_s,
                              :order=>[:created_at.desc]
                            )
    ).render
  end

  get '/posts/category/:category/' do |category|
    (PostsView.new request, Category.all(
                              :name=>category
                            ).posts.sort.reverse
    ).render
  end

  get '/posts/create/' do
    (PostCreateView.new request).render
  end

  post '/posts/create/' do
    new_post = Post.create(
                 :title=>params['title'],
                 :body=>params['body'].gsub("\n","<br />")
              )

    categories = params['categories'].split(',')
    categories.each do |category|
      added_category = Category.first_or_create(:name=>category)
      new_post.categories << added_category
    end

    new_post.save
    redirect '/posts/'
  end
  
  set :public_folder, File.dirname(__FILE__) + '/media'
end

BlogController.run!
