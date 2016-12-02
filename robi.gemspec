Gem::Specification.new do |spec|
  spec.name          = 'Rindle'
  spec.version       = '1.0'
  spec.authors       = ['Andrew Tolvstad']
  spec.license       = 'Apache 2.0'

  spec.files         = %w(
    lib/optparser.rb
    lib/robi.rb
    lib/robi/fetcher.rb
    lib/robi/compiler.rb
    lib/robi/post.rb
    lib/static/stylesheet.css
  )
  spec.executables   = ['bin/robi']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'nokogiri'
end
