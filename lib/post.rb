require 'time'

module Rindle
  class Post
    attr_reader *%i(title author date body comment_count points)
    def initialize(title, author, date, body, comment_count, points)
      @title = title.to_s
      @author = author.to_s
      @date = Time.parse(date.to_s)
      @body = body.to_s
      @comment_count = comment_count.to_i
      @points = points
    end
  end
end
