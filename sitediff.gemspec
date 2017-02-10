Gem::Specification.new do |s|
  s.name        = 'sitediff'
  s.version     = '0.0.4'
  s.required_ruby_version = ">= 1.9.3"
  s.summary     = 'Compare two versions of a site with ease!'
  s.description = <<EOS
SiteDiff makes it easy to see differences between two versions of a website. It accepts a set of paths to compare two versions of the site together with potential normalization/sanitization rules. From the provided paths and configuration SiteDiff generates an HTML report of all the status of HTML comparison between the given paths together with a readable diff-like HTML for each specified path containing the differences between the two versions of the site. It is useful tool for QAing re-deployments, site upgrades, etc.
EOS
  s.license     = 'GPL-2.0'
  s.authors     = ['Alex Dergachev', 'Amir Kadivar', 'Dave Vasilevsky']
  s.homepage    = 'https://github.com/evolvingweb/sitediff/'
  s.email       = 'alex@evolvingweb.ca'
  s.files       = Dir.glob('lib/**/*.rb') +
                  Dir.glob('lib/sitediff/files/*') +
                  Dir.glob('lib/sitediff/files/rules/*.yaml')
  s.bindir      = 'bin'
  s.executables = 'sitediff'

  s.add_dependency 'thor', '~> 0.19.0'
  s.add_dependency 'typhoeus', '~> 1.0'

  # A bug in rubygems can break rainbow 2.2
  # https://github.com/bundler/bundler/issues/5357
  s.add_dependency 'rainbow', '~> 2.0', '< 2.2'

  # Nokogiri 1.7 is not supported on Ruby 2.0.
  s.add_dependency 'nokogiri', '~> 1.0', '< 1.7'

  # Diffy and addressable have a max version for Ruby 1.9.
  s.add_dependency 'diffy', '~> 3.0', '< 3.0.5'
  s.add_dependency 'addressable', '~> 2.0', '< 2.5'
end
