require_relative 'models.rb'
require_relative 'views.rb'

class PostsController
  def _get_last_posts
    Post.all(:order=>[:created_at.desc], :limit=>5)
  end

  def _sanitize_line_breaks message
    message.gsub("\n", "<br />")
  end

  def _comment_url url
    return url if url.include? "http://"
    "http://" + url
  end

  def _render_posts_helper view, request, posts_to_render
    (view.new request, posts_to_render, _get_last_posts).render
  end

  def _render_single_post request, post_to_render
    _render_posts_helper PostDetailView, request, post_to_render
  end

  def _render_posts request, posts_to_render
    _render_posts_helper PostsView, request, posts_to_render
  end

  def _validate_create *args
    raise "creation error" if args.any? { |e| e.empty? }
  end

  def render_by_id request, post_id
    _render_single_post request, Post.get(post_id)
  end

  def render_by_category request, category
    _render_posts request,
                  Category.all(
                    :name=>category
                  ).posts.sort.reverse
  end

  def render_by_date request, date
    _render_posts request,
                  Post.all(
                    :created_at.gt=>date.to_s,
                    :created_at.lt=>(date + 1).to_s,
                    :order=>[:created_at.desc]
                  )
  end

  def render_for_page request, page_number
    _render_posts request,
                  Post.all(
                    :order=>[:created_at.desc],
                    :limit=>10,
                    :id.gt=>(page_number * 10)
                  )
  end

  def render_all request
    _render_posts request,
                  Post.all(:order=>[:created_at.desc], :limit=>10)
  end

  def create_post_form request
    (PostCreateView.new request).render
  end

  def create_post title, body, categories
    _validate_create title, body
    new_post = Post.create(
                 :title=>params['title'],
                 :body=>(_sanitize_line_breaks params['body'])
               )

    categories.each do |category|
      added_category = Category.first_or_create(:name=>category)
      new_post.categories << added_category
    end

    new_post.save
  end

  def create_comment_for post_id, name, url, message
    post = Post.get(post_id)
    _validate_create name, message

    new_comment = Comment.create(
                    :posted_by=>name,
                    :url=>(_comment_url url),
                    :body=>(_sanitize_line_breaks body)
                  )
    post.comments << new_comment
    post.save
  end
end

class StaticsController
  def index request
    (IndexView.new request).render
  end

  def about request
    (AboutView.new request).render
  end
end
