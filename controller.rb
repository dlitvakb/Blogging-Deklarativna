require_relative 'models.rb'
require_relative 'views.rb'
require 'sinatra/base'

class BlogController < Sinatra::Base
  def _get_last_posts
    Post.all(:order=>[:created_at.desc], :limit=>5)
  end

  def _render_posts request, posts_to_render
    (PostsView.new request, posts_to_render, _get_last_posts).render
  end

  get '/' do
    (IndexView.new request).render
  end

  get '/about/' do
    (AboutView.new request).render
  end

  get '/posts/' do
    _render_posts request,
                  Post.all(:order=>[:created_at.desc], :limit=>10)
  end

  get '/posts/page/:page/' do |page|
    _render_posts request,
                  Post.all(
                    :order=>[:created_at.desc],
                    :limit=>10,
                    :id.gt=>(page.to_i * 10)
                  )
  end

  get '/posts/:post_id/' do |post_id|
    _render_posts request, [Post.get(post_id)]
  end

  get %r{/posts/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/?} do
    date = Date.new params[:year].to_i,
                    params[:month].to_i,
                    params[:day].to_i
    _render_posts request,
                  Post.all(
                    :created_at.gt=>date.to_s,
                    :created_at.lt=>(date + 1).to_s,
                    :order=>[:created_at.desc]
                  )
  end

  get '/posts/category/:category/' do |category|
    _render_posts request,
                  Category.all(
                    :name=>category
                  ).posts.sort.reverse
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
