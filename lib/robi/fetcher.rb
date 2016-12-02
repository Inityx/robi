require 'net/http'
require 'json'
require 'pp'

require 'robi/post'

class Robi
  class Fetcher
    HTTP_SUCCESS = %w(200).map(&:freeze).freeze
    HTTP_REDIRECT = %w(301 302).map(&:freeze).freeze

    def initialize(subreddit, type)
      @uri = URI("https://reddit.com/r/#{subreddit}/#{type}/.json")
    end

    def fetch(count)
      puts "  Connecting to #{@uri}..."
      response = Net::HTTP.get_response(@uri)

      while HTTP_REDIRECT.include?(response.code)
        @uri = URI(response.header['location'])
        puts "  Redirecting to #{@uri}..."
        response = Net::HTTP.get_response(@uri)
      end

      unless HTTP_SUCCESS.include?(response.code)
        raise "Received response code #{response.code}: #{response.msg}"
      end

      json = response.body

      puts '  Extracting content...'
      obj = JSON.parse(json)
      extract(count, obj)
    end

    def extract(count, obj)
      obj['data']['children']
        .map { |post| post['data'] }
        .reject { |post| post['stickied'] }
        .reject { |post| post['selftext'].empty? }
        .first(count)
        .map { |post| Post.from_json_hash(post) }
    end
  end
end
