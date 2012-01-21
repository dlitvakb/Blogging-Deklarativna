require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///#{File.dirname(__FILE__)}/blogging.db")

class Post
  include DataMapper::Resource

  property :id,         Serial
  property :title,      String, :required => true
  property :body,       Text,   :required => true
  property :created_at, DateTime

  has n, :comments
  has n, :categorizations
  has n, :categories, :through => :categorizations
end

class Comment
  include DataMapper::Resource

  property :id,         Serial
  property :posted_by,  String, :required => true
  property :url,        String, :format => :url
  property :body,       Text,   :required => true
  property :created_at, DateTime

  belongs_to :post
end

class Category
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String

  has n, :categorizations
  has n, :posts, :through => :categorizations
end

class Categorization
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime

  belongs_to :category
  belongs_to :post
end

class User
  include DataMapper::Resource

  property :id,         Serial
  property :user_name,  String, :required => true, :unique => true
  property :password,   String, :length => 40, :required => true
  property :email,      String, :format => :email_address
  property :is_admin,   Boolean, :default => false
end

DataMapper.finalize
