require 'time'

module Rindle
  class Post
    attr_reader *%i(uid title author date body comment_count points)
    def initialize(uid, title, author, timestamp, body, comment_count, points)
      @uid = uid.to_s
      @title = title.to_s
      @author = author.to_s
      @date = Time.at(timestamp.to_i)
      @body = body.to_s
      @comment_count = comment_count.to_i
      @points = points
    end
    
    def self.from_json_hash(hash)
      new(
        *hash.values_at(
          *%w(name title author created selftext_html num_comments score)
        )
      )
    end
  end
end
