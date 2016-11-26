require 'net/http'
require 'json'
require 'pp'

require './lib/post'

HTTP_SUCCESS = %w(200).map(&:freeze).freeze
HTTP_REDIRECT = %w(301 302).map(&:freeze).freeze

module Rindle
  class Fetcher
    def initialize(subreddit, type = hot)
      @uri = URI("https://reddit.com/r/#{subreddit}/#{type}/.json")
    end

    def fetch(count)
      puts "Fetching #{@uri}..."
      response = Net::HTTP.get_response(@uri)

      while HTTP_REDIRECT.include?(response.code)
        @uri = URI(response.header['location'])
        puts "Redirecting to #{@uri}..."
        response = Net::HTTP.get_response(@uri)
      end

      unless HTTP_SUCCESS.include?(response.code)
        raise "Received response code #{response.code}: #{response.message}"
      end

      json = response.body
      obj = JSON.parse(json)
      extract(count, obj)
    end

    def extract(count, obj)
      obj['data']['children']
        .map { |post| post['data'] }
        .reject { |post| post['stickied'] }
        .reject { |post| post['selftext'].empty? }
        .first(count)
        .map { |post| Rindle::Post.from_json_hash(post) }
    end
  end
end
