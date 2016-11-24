require 'net/http'
require 'json'
require 'pp'

require './lib/post'

module Rindle
  class Fetcher
    def initialize(subreddit, type)
      @uri = URI("https://reddit.com/r/#{subreddit}/#{type}.json")
    end

    def fetch(count)
      puts 'Fetching'
      json = Net::HTTP.get(@uri)
      raise 'No data fetched' if json.nil? || json.empty?

      obj = JSON.parse(json)
      extract(count, obj)
    end

    def extract(count, obj)
      puts 'Posts:'
      obj['data']['children'].each { |child| pp child.keys }
        # .first(count)
        # .map { |post| Rindle::Post.from_json_hash(post) }
    end
  end
end
