require 'time'

require 'robi/fetcher'
require 'robi/compiler'

class Robi
  def initialize(subreddit, type)
    @subreddit = subreddit
    @type = type
  end

  def bundle(count)
    id = [@subreddit, @type, Time.now.strftime('%Y-%m-%d-%H%M')]

    title_string = id.join(' ')
    title_slug = id.join('_')
    dest_dir = "./#{title_slug}"

    if Dir.exist?(dest_dir) && (Dir.entries(dest_dir) - %w(. ..)).any?
      raise "#{dest_dir} not empty"
    end

    puts 'Locating kindlegen'
    kindlegen_found = system('which kindlegen')
    abort unless kindlegen_found

    puts "\nFetching posts"
    posts = Fetcher.new(@subreddit, @type).fetch(count)

    puts "\nCompiling to eBook source"
    stylesheet = File.expand_path('stylesheet.css', "#{File.dirname(__FILE__)}/static")
    metadata_file = Compiler.new(dest_dir, stylesheet)
                                    .compile(title_string, posts)

    puts "\nInvoking kindlegen"
    outfile = "#{File.dirname(metadata_file)}/output.mobi"
    system("kindlegen #{metadata_file} -o output.mobi")
    raise 'kindlegen failed to output eBook' unless File.exist?(outfile)
    FileUtils.mv(outfile, "./#{title_slug}.mobi")
  end
end
