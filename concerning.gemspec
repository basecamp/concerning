Gem::Specification.new do |s|
  s.name      = 'concerning'
  s.version   = '1.0.2'
  s.author    = 'Jeremy Kemper'
  s.email     = 'jeremy@basecamp.com'
  s.homepage  = 'https://github.com/basecamp/concerning'
  s.summary   = 'Separating small concerns'
  s.license   = 'MIT'

  s.add_runtime_dependency 'activesupport', '>= 3.0.0'
  s.add_development_dependency 'minitest'

  s.files = Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"]
end
