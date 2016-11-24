require './lib/post'

module Rindle
  class Fetcher
    def initialize(subreddit, listing_type)
    end

    def fetch(_)
      Array[
        Rindle::Post.new(
          'This first tile',
          'mr_giblets',
          '2007-05-21',
          'This is the body of the first post. Not sure of the format.',
          5,
          200
        )
      ]
    end
  end
end
