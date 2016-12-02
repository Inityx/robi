require 'optparse'

module OptParser
  TYPES = %i(hot new rising controversial top gilded).freeze

  def self.parse
    opt = {}

    OptionParser.new { |options|
      options.banner = 'Usage: robi SUBREDDIT [-t TYPE] [-c COUNT]'

      opt[:subreddit] = ARGV.first
      opt[:type] = :hot
      opt[:count] = 25

      options.on('-t', '--type TYPE', 'top, new, etc. (default hot)') { |type|
        opt[:type] = type.downcase.to_sym
      }
      
      options.on('-c', '--count COUNT', 'Max number of posts (default 25)') { |count|
        opt[:count] = count.to_i
      }

      options.on('-h', '--help', 'Display this screen') {
        puts options
        exit
      }
    }.parse!

    raise 'No subreddit specified' if opt[:subreddit].nil?
    raise "Subreddit name must be raw ('funny' or 'pics')" if opt[:subreddit].include?('/')
    raise "Type must be one of {#{TYPES.join(', ')}}" unless TYPES.include?(opt[:type])
    raise 'Count must be at least 1' if opt[:count] < 1

    opt
  end
end
