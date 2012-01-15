require 'deklarativna'

class BaseView < BaseTemplate
  def initialize request
    @request = request
    @title = "Deklarativna"
  end

  def _stylesheets
    [
      link("rel"=>"stylesheet",
           "href"=>"/css/bootstrap.css",
           "type"=>"text/css"),
      link("rel"=>"stylesheet",
           "href"=>"/css/styles.css",
           "type"=>"text/css")
    ]
  end

  def _scripts
    [
      javascript("src"=>"http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"),
    ]
  end

  def _head
    [
      title { @title }
    ] + _stylesheets + _scripts + _extra_head
  end

  def _extra_head
    []
  end

  def __nav_bar_item text, link, active_condition
    li("class"=>("active" if active_condition)) {
      a("href"=>link) { text }
    }
  end

  def _nav_bar_items
    [
      (__nav_bar_item "Home", "/", (@request.path_info == "/")),
      (__nav_bar_item "About", "/about/", (@request.path_info == "/about/")),
      (__nav_bar_item "Blog", "/posts/", (/\/posts.*/.match @request.path_info))
    ]
  end

  def _nav_bar
    ul("class"=>"nav", "style"=>"float:right;") { _nav_bar_items }
  end

  def _topbar
    div("class"=>"topbar") {
      div("class"=>"fill") {
        div("class"=>"container") {[
            a("class"=>"brand", "href"=>"/") { "Deklarativna" },
            _nav_bar
        ]}
      }
    }
  end

  def _footer
    footer("style"=>"text-align:center;") {
      span { "&copy; 2012 David Litvak Bruno" }
    }
  end

  def _body
    content + [_footer]
  end

  def content
    [
      _topbar,
      div("class"=>"container") {
        [
          div("class"=>"content", "id"=>"content") {
          _content
          }
        ] + _extra_content
      }
    ] + _extra_body
  end

  def _content
    []
  end

  def _extra_content
    []
  end

  def _extra_body
    []
  end
end

class IndexView < BaseView
end

class AboutView < BaseView
  def initialize request
    super request
    @title = "Deklarativna's Blog - About"
  end

  def _about_me
    p { "My name is #{b { "David Litvak Bruno" }}, 
         I'm a software developer from Argentina. #{br}
         I'm a framework development devotee,
         and my main programming languages are
         #{i { "Python, Ruby and Java" }}. #{br}
         I wrote Deklarativna as teaching material for
         the Advanced Object Oriented Programming course I'm an
         assistant teacher in. #{br}
         It has been a great and rewarding experience and I hope
         other people find also this piece of software usefull "
    }
  end

  def _email
    a("href"=>"mailto:david.litvakb@gmail.com") {
      "david (dot) litvakb (at) gmail (dot) com"
    }
  end

  def _twitter
    a("href"=>"www.twitter.com/dlitvakb") { "Twitter" }
  end

  def _github
    a("href"=>"www.github.com/dlitvakb") { "GitHub" }
  end

  def _contact_info
    [
      p { "You can contact me at #{_email}" },
      p { "You can also follow me at #{_github} or #{_twitter}." }
    ]
  end

  def _content
    [
      h2 { "About me..." },
      div {
        [
          _about_me
        ] + _contact_info
      }
    ]
  end
end

class PostsView < BaseView
  def initialize request, posts
    super request
    @posts = posts
    @title = "Deklarativna's Blog"
  end

  def _nav_bar_items
    super << (__nav_bar_item "Create Post", "/posts/create/", false)
  end

  def _render_post post
    categories = []
    post.categories.each do |category|
      categories << a("href"=>"/posts/category/#{category.name}") { category.name }
    end
    [
      h2 { post.title },
      p { post.body },
      h6 { categories.join(" ") }
    ]
  end

  def _content
    posts_content = []
    @posts.each do |e|
      posts_content += _render_post e
    end
    posts_content
  end
end

class FormView < BaseView
  def _input label_text, label_for, widget
    div("class"=>"clearfix") {[
      label("for"=>label_for) { label_text },
      div("class"=>"input") { widget }
    ]}
  end

  def _submit text
    div("class"=>"clearfix") {
      div("class"=>"input") {
        submit("value"=>text)
      }
    }
  end
end

class PostCreateView < FormView
  def initialize request
    super request
    @title = "Deklarativna's Blog - New Post"
  end

  def _form
    form("method"=>"post","action"=>"/posts/create/") {[
      (_input "Title", "title", text("name"=>"title")),
      (_input "Body", "body", textarea("name"=>"body", "rows"=>"10")),
      (_input "Categories", "categories", text("name"=>"categories")),
      _submit("Post!")
    ]}
  end

  def _content
    [
      h2 { "New Post..." },
      _form
    ]
  end
end
