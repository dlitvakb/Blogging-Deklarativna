require_relative 'models.rb'
require_relative 'views.rb'
require 'sinatra/base'

class BlogController < Sinatra::Base
  def _get_last_posts
    Post.all(:order=>[:created_at.desc], :limit=>5)
  end

  def _render_posts_helper view, request, posts_to_render
    (view.new request, posts_to_render, _get_last_posts).render
  end

  def _render_posts request, posts_to_render
    _render_posts_helper PostsView, request, posts_to_render
  end

  def _render_single_post request, post_to_render
    _render_posts_helper PostDetailView, request, post_to_render
  end

  def _sanitize_line_breaks message
    message.gsub("\n", "<br />")
  end

  def _comment_url url
    return url if url.include? "http://"
    "http://" + url
  end

  def _validate_comment_create params
    raise "creation error" if params['body'] == "" or params["posted_by"] == ""
  end

  def _validate_comment_create params
    raise "creation error" if params['body'] == "" or params["title"] == ""
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
    _render_single_post request, Post.get(post_id)
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

  post '/posts/:post_id/comments/create/' do |post_id|
    post = Post.get(post_id)
    begin
      _validate_comment_create params

      new_comment = Comment.create(
                      :posted_by=>params['posted_by'],
                      :url=>(_comment_url params['url']),
                      :body=>(_sanitize_line_breaks params['body'])
                    )
      post.comments << new_comment
      post.save
    ensure
      redirect "/posts/#{post_id}/"
    end
  end

  get '/posts/category/:category/' do |category|
    _render_posts request,
                  Category.all(
                    :name=>category
                  ).posts.sort.reverse
  end

  get '/post/create/' do
    (PostCreateView.new request).render
  end

  post '/post/create/' do
    begin
      _validate_post_create params
      new_post = Post.create(
                   :title=>params['title'],
                   :body=>(_sanitize_line_breaks params['body'])
                )

      categories = params['categories'].split(',')
      categories.each do |category|
        added_category = Category.first_or_create(:name=>category)
        new_post.categories << added_category
      end

      new_post.save
    ensure
      redirect '/posts/'
    end
  end

  set :public_folder, File.dirname(__FILE__) + '/media'
end

BlogController.run!
