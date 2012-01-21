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
      javascript("src"=>"http://code.jquery.com/jquery-latest.js"),
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

class IndexView < BaseView
  def _content
    [
      div("class"=>"hero-unit") {[
        h1 { "Deklarativna's Blog" },
        p { "A blog about declarative programming" },
        p {
          a("href"=>"/posts/", "class"=>"btn primary large") {
            "To the Posts! &raquo;"
          }
        }
      ]},
      div("class"=>"row") {[
        div("class"=>"span5") {[
          h2 { "A little bit about me" },
          p {
            "I'm an enthusiastic programmer interested in
             new ways to develop, always trying to expand and extend
             the tools and help people to discover more and more..."
            },
          br,
          p {
            a("href"=>"/about/", "class"=>"btn") {
              "About me &raquo;"
            }
          }
        ]},
        div("class"=>"span6") {[
          h2 { "About Deklarativna" },
          p {
            "Deklarativna is a templating framework for ruby. #{br}
             The idea after it, was to allow developers to write
             the html templates in ruby code, and to allow them to
             have a fully integrated frontend development experience. #{br}
             Also, it was created as teaching material for my students."
          },
          p {
            a("href"=>"http://www.github.com/dlitvakb/deklarativna",
              "class"=>"btn") {
              "Find out more! &raquo;"
            }
          }
        ]},
        div("class"=>"span6") {[
          h2 { "What other resources do I use?" },
          p {
            "As I intend to program this blog in a fully declarative way,
             I've found that the best resources to fit my intentions were
             #{a("href"=>"http://www.sinatrarb.com") {"Sinatra"}} and
             #{a("href"=>"http://www.datamapper.org") {"DataMapper"}}. #{br}
             As I've found #{a("href"=>"http://www.ruby-lang.org") {"Ruby"}}
             to be an amazing programming language to write in a
             declarative way, it has been, therefore my desicion to use it"
          }
        ]}
      ]}
    ]
  end
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
    a("href"=>"http://www.twitter.com/dlitvakb") { "Twitter" }
  end

  def _github
    a("href"=>"http://www.github.com/dlitvakb") { "GitHub" }
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
  def initialize request, displaying_posts, recent_posts=nil
    super request
    @displaying_posts = displaying_posts
    @recent_posts = recent_posts
    @title = "Deklarativna's Blog"
  end

  def _nav_bar_items
    super << (__nav_bar_item "Create Post",
                             "/post/create/",
                             (@request.path_info == '/post/create/')
             )
  end

  def _categories post
    categories = []
    post.categories.each do |category|
      categories << a("href"=>"/posts/category/#{category.name}/") {
                      category.name
                    }
    end
    categories
  end

  def _sanitize_iso_timestamp timestamp
    date_iso_splitted = timestamp.split("T")
    date_iso_splitted[1] = date_iso_splitted[1].split("-")[0]
    date_iso_splitted
  end

  def _posted_at post
    datetime = (_sanitize_iso_timestamp post.created_at.to_s)
    date_part = datetime[0].split("-")
    year = date_part[0]
    month = date_part[1]
    day = date_part[2]

    a("href"=>"/posts/#{year}/#{month}/#{day}/") {
      datetime.join(" ")
    }
  end

  def _comments_extra post
    a("href"=>"/posts/#{post.id}/#comments", "class"=>"extra-comments") {
      "Comments (#{post.comments.size})"
    }
  end

  def _render_post post
    [
      div("class"=>"post") {[
        h2 { a("href"=>"/posts/#{post.id}/") { post.title }},
        p("class"=>"post-body") { post.body },
        p("class"=>"categories") {
          [ "Category: ", (_categories post).join(" ") ]
        },
        p("class"=>"posted-at") {
          "Posted at #{i { _posted_at post }}" + (_comments_extra post)
        }
      ]}
    ]
  end

  def _posts
    posts_content = []
    @displaying_posts.each do |e|
      posts_content += _render_post e
    end
    posts_content
  end

  def _recent_posts
    recent_posts = []
    @recent_posts.each do |e|
      recent_posts << p { a("href"=>"/posts/#{e.id}/") { e.title } }
    end
    recent_posts
  end

  def _sidebar
    [
      h3 { a("href"=>"/") { "Deklarativna" }},
      hr,
      h4 { "Recent Posts" }
    ] + _recent_posts
  end

  def _content
    [
      div("class"=>"row") {[
        div("id"=>"posts", "class"=>"span12") { _posts },
        div("id"=>"sidebar", "class"=>"span4") { _sidebar }
      ]}
    ]
  end
end

class PostDetailView < PostsView
  def initialize request, post, recent_posts=nil
    @request = request
    @post = post
    @recent_posts = recent_posts
    @title = "Deklarativna's Blog - #{@post.title}"
  end

  def _comments_extra post
    ""
  end

  def _commentor comment
    return (a("href"=>comment.url) { comment.posted_by }) if !comment.url.empty?
    comment.posted_by
  end

  def _comment comment
    datetime = (_sanitize_iso_timestamp comment.created_at.to_s)

    div("class"=>"comment") {[
      h3 { _commentor comment},
      p { comment.body },
      p("class"=>"posted-at") {
        "#{_commentor comment} wrote this at #{datetime[0]} #{datetime[1]}"
      }
    ]}
  end

  def _render_comments post
    comments = []
    post.comments.each { |e|
      comments << (_comment e)
    }
    comments
  end

  def _comments post
    div("class"=>"comments", "id"=>"comments") {[
      h3 { "Comments (#{post.comments.size})" }
      ] + (_render_comments post)
    }
  end

  def _new_comment_form
    form("class"=>"comment-form",
         "method"=>"post",
         "action"=>"/posts/#{@post.id}/comments/create/") {[
      h5 { "Add your comments:" },
      (_input "Name", "name", text("name"=>"posted_by")),
      (_input "Website (Optional)", "url", text("name"=>"url")),
      (_input "Message", "message", textarea("name"=>"body", "rows"=>"5")),
      _submit("Comment!")
    ]}
  end

  def _render_post post
    (super post) << (_comments post) << (_new_comment_form)
  end

  def _posts
    [
      (_render_post @post)
    ]
  end
end

class PostCreateView < PostsView
  def initialize request
    @request = request
    @title = "Deklarativna's Blog - New Post"
  end

  def _form
    form("method"=>"post","action"=>"/post/create/") {[
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

class UserCreateView < PostsView
  def initialize request
    @request = request
    @title = "Deklarativna's Blog - New User"
  end

  def _form
    form("method"=>"post","action"=>"/user/create/") {[
      (_input "Name", "name", text("name"=>"name")),
      (_input "Password", "password", password("name"=>"password")),
      (_input "E-Mail", "email", text("name"=>"email")),
      _submit("Create!")
    ]}
  end

  def _content
    [
      h2 { "New User..." },
      _form
    ]
  end
end
