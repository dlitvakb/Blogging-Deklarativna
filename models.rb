require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///#{File.dirname(__FILE__)}/blogging.db")


class Post
  include DataMapper::Resource

  property :id,         Serial    
  property :title,      String    
  property :body,       Text      
  property :created_at, DateTime  

  has n, :comments
  has n, :categorizations
  has n, :categories, :through => :categorizations
end

class Comment
  include DataMapper::Resource

  property :id,         Serial
  property :posted_by,  String
  property :email,      String
  property :url,        String
  property :body,       Text

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

DataMapper.finalize
