Gem::Specification.new do |spec|
  spec.name           = 'robi'
  spec.version        = '0.0.1'
  spec.date           = '2016-12-02'
  spec.summary        = 'Robi'
  spec.description    = 'Compile Reddit to Kindle eBooks'
  spec.authors        = ['Andrew Tolvstad']
  spec.email          = 'tolvstaa@oregonstate.edu'
  spec.license        = 'Apache-2.0'
  spec.homepage       = 'https://github.com/Inityx/robi'

  spec.files          = %w(
    lib/optparser.rb
    lib/robi.rb
    lib/robi/fetcher.rb
    lib/robi/compiler.rb
    lib/robi/post.rb
    lib/static/stylesheet.css
  )
  spec.executables    = ['robi']
  spec.require_paths  = ['lib']

  spec.add_runtime_dependency 'nokogiri', '~> 1.6', '>=1.6.8'
end
